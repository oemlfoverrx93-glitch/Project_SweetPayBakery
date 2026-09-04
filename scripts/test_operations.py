"""Build and verify against a newly created, disposable SQL Server database.

Example: python scripts/test_operations.py --tomcat-home C:/apache-tomcat-9 --http
SQLCMD uses the current Windows account. Java uses SWEETPAY_DB_USER/PASSWORD.
Never applies schema changes to SweetPayBakery. Requires Python 3.9+, JDK 21+.
"""
import argparse, datetime, os, pathlib, shutil, subprocess, time, urllib.request

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--tomcat-home',required=True)
    parser.add_argument('--server',default='localhost,1433')
    parser.add_argument('--http',action='store_true',help='Also run HTTP and Playwright browser tests on port 18081')
    parser.add_argument('--keep-database',action='store_true',help='Keep the test database for inspection')
    args=parser.parse_args()
    root=pathlib.Path(__file__).resolve().parents[1]
    home=pathlib.Path(args.tomcat_home).resolve()
    assert (home/'lib/servlet-api.jar').exists(), 'Tomcat 9 is required (javax.servlet)'
    jhome=os.environ.get('JAVA_HOME')
    java=str(pathlib.Path(jhome)/'bin/java.exe') if jhome else shutil.which('java')
    javac=str(pathlib.Path(jhome)/'bin/javac.exe') if jhome else shutil.which('javac')
    assert java and javac, 'Install JDK 21 or set JAVA_HOME'
    stamp=datetime.datetime.now().strftime('%Y%m%d%H%M%S%f')
    db='SweetPayBakeryOpsTest'+stamp
    run=root/'.tools/tests'/stamp;run.mkdir(parents=True)
    sqlcmd=['sqlcmd','-S',args.server,'-E','-C','-b','-f','65001']
    logs=[]
    def command(cmd):
        result=subprocess.run(cmd,cwd=root,text=True,encoding='utf-8',errors='replace',stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
        print(result.stdout);logs.append(result.stdout)
        if result.returncode: raise RuntimeError('Verification command failed: '+str(cmd[0]))
    jdbc='jdbc:sqlserver://'+args.server.replace(',',':')+';databaseName='+db+';encrypt=true;trustServerCertificate=true;loginTimeout=3;'
    process=None;created=False
    try:
        source=(root/'sql/01_schema.sql').read_text(encoding='utf-8')
        schema='CREATE DATABASE '+db+';\nGO\nUSE '+db+';\nGO\n'+source[source.index('-- 1. Roles'):]
        (run/'schema.sql').write_text(schema,encoding='utf-8')
        command(sqlcmd+['-i',str(run/'schema.sql')]);created=True
        migration=(root/'sql/09_ecommerce_operations.sql').read_text(encoding='utf-8').replace('SweetPayBakery',db)
        (run/'migration.sql').write_text(migration,encoding='utf-8')
        command(sqlcmd+['-i',str(run/'migration.sql')]);command(sqlcmd+['-i',str(run/'migration.sql')])
        classes=run/'classes';classes.mkdir()
        sources=list((root/'src/java').rglob('*.java'))+[root/'test/com/sweetpay/OperationsIntegrationTest.java']
        (run/'sources.txt').write_text('\n'.join('"'+p.as_posix()+'"' for p in sources),encoding='utf-8')
        cp=os.pathsep.join([str(root/'web/WEB-INF/lib/*'),str(home/'lib/*')])
        command([javac,'--release','21','-encoding','UTF-8','-cp',cp,'-d',str(classes),'@'+str(run/'sources.txt')])
        command([java,'-Dsweetpay.db.url='+jdbc,'-cp',str(classes)+os.pathsep+cp,'com.sweetpay.OperationsIntegrationTest'])
        if args.http:
            import socket
            with socket.socket() as sock:
                assert sock.connect_ex(('127.0.0.1',18081))!=0, 'Port 18081 is already in use; stop the previous test server first.'
            base=run/'tomcat';web=run/'web'
            for folder in ['conf/Catalina/localhost','logs','temp','work','webapps']:(base/folder).mkdir(parents=True,exist_ok=True)
            for f in (home/'conf').iterdir():
                if f.is_file():shutil.copy2(f,base/'conf'/f.name)
            shutil.copytree(root/'web',web);shutil.copytree(classes,web/'WEB-INF/classes',dirs_exist_ok=True)
            server=(base/'conf/server.xml').read_text(encoding='utf-8').replace('port="8080"','port="18081"').replace('port="8005"','port="-1"')
            (base/'conf/server.xml').write_text(server,encoding='utf-8')
            (base/'conf/Catalina/localhost/SweetBakery.xml').write_text('<Context docBase="'+web.as_posix()+'" />',encoding='utf-8')
            cmd=[java,'-Dcatalina.base='+str(base),'-Dcatalina.home='+str(home),'-Djava.io.tmpdir='+str(base/'temp'),'-Djava.util.logging.config.file='+str(base/'conf/logging.properties'),'-Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager','-Dsweetpay.db.url='+jdbc,'-DVNPAY_TMN_CODE=TESTONLY','-DVNPAY_HASH_SECRET=isolated-test-signing-key-not-a-merchant-credential','-DVNPAY_RETURN_URL=http://localhost:18081/SweetBakery/payments/vnpay/return','-cp',os.pathsep.join([str(home/'bin/bootstrap.jar'),str(home/'bin/tomcat-juli.jar')]),'org.apache.catalina.startup.Bootstrap','start']
            with (run/'server.log').open('w',encoding='utf-8') as output:
                process=subprocess.Popen(cmd,stdout=output,stderr=subprocess.STDOUT,creationflags=getattr(subprocess,'CREATE_NO_WINDOW',0))
            for _ in range(40):
                try:
                    with urllib.request.urlopen('http://localhost:18081/SweetBakery/login',timeout=2) as response:
                        if response.status==200:break
                except OSError:time.sleep(.5)
            command([shutil.which('node') or 'node',str(root/'test/http_operations_test.cjs')])
    finally:
        if process:
            process.terminate()
            try:process.wait(timeout=10)
            except subprocess.TimeoutExpired:process.kill();process.wait()
        if created and not args.keep_database:
            assert db.startswith('SweetPayBakeryOpsTest') and db[len('SweetPayBakeryOpsTest'):].isdigit()
            command(sqlcmd+['-Q','ALTER DATABASE ['+db+'] SET SINGLE_USER WITH ROLLBACK IMMEDIATE; DROP DATABASE ['+db+'];'])
        (run/'results.txt').write_text('\n'.join(logs),encoding='utf-8')
        print('Test evidence:',run)
if __name__=='__main__':main()
