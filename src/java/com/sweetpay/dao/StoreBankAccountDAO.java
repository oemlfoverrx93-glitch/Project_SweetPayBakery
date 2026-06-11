package com.sweetpay.dao;

import com.sweetpay.model.StoreBankAccount;
import com.sweetpay.util.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class StoreBankAccountDAO {

    public StoreBankAccount getDefaultAccount() {
        StoreBankAccount account = null;
        String query = "SELECT TOP 1 * FROM store_bank_account WHERE is_default = 1";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(query);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                account = new StoreBankAccount();
                account.setAccountId(rs.getInt("account_id"));
                account.setBankName(rs.getString("bank_name"));
                account.setAccountNumber(rs.getString("account_number"));
                account.setAccountHolder(rs.getString("account_holder"));
                account.setBinCode(rs.getString("bin_code"));
                account.setDefault(rs.getBoolean("is_default"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return account;
    }
}
