package com.example.demo.util;

import javax.crypto.Cipher;
import java.security.*;
import java.util.Base64;

public class RSAUtil {
    private KeyPair keyPair;

    public RSAUtil() throws NoSuchAlgorithmException {
        KeyPairGenerator keyGen = KeyPairGenerator.getInstance("RSA");
        keyGen.initialize(2048);
        this.keyPair = keyGen.generateKeyPair();
    }

    public String encrypt(String plainText) throws Exception {
        Cipher cipher = Cipher.getInstance("RSA");
        cipher.init(Cipher.ENCRYPT_MODE, keyPair.getPublic());
        byte[] encryptedBytes = cipher.doFinal(plainText.getBytes());
        return Base64.getEncoder().encodeToString(encryptedBytes);
    }

    public String decrypt(String encryptedText) throws Exception {
        Cipher cipher = Cipher.getInstance("RSA");
        cipher.init(Cipher.DECRYPT_MODE, keyPair.getPrivate());
        byte[] decryptedBytes = cipher.doFinal(Base64.getDecoder().decode(encryptedText));
        return new String(decryptedBytes);
    }

    public PublicKey getPublicKey() {
        return keyPair.getPublic();
    }

    public PrivateKey getPrivateKey() {
        return keyPair.getPrivate();
    }

    // 샘플 테스트용 main 메서드
    public static void main(String[] args) throws Exception {
        RSAUtil rsaUtil = new RSAUtil();
        String original = "암호화할 데이터 예시";
        String encrypted = rsaUtil.encrypt(original);
        String decrypted = rsaUtil.decrypt(encrypted);
        System.out.println("원본: " + original);
        System.out.println("암호화: " + encrypted);
        System.out.println("복호화: " + decrypted);
    }
}
