package com.wolfpeng.util;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.security.SignatureException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.SimpleTimeZone;
import java.util.UUID;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

import org.apache.log4j.Level;
import org.apache.log4j.Logger;
import sun.misc.BASE64Encoder;

/**
 *
 * @author penghao
 * @date 2018/1/9
 * Copyright © 2017年 Alibaba. All rights reserved.
 */
public class OpenApiUtil {

    private final static String VOD_DOMAIN = "http://vod.cn-shanghai.aliyuncs.com";
    private final static String ISO8601_DATE_FORMAT = "yyyy-MM-dd'T'HH:mm:ss'Z'";
    private final static String HTTP_METHOD = "GET";
    private final static String HMAC_SHA1_ALGORITHM = "HmacSHA1";
    private final static Logger LOG = Logger.getLogger(OpenApiUtil.class.getName());


    /**
     * 生成视频点播OpenAPI公共参数
     * 不需要修改
     *
     * @return 公共参数结果
     */
    private static Map<String, String> generatePublicParamters(String accessKeyId, String securityToken) {
        Map<String, String> publicParams = new HashMap<>(8);
        publicParams.put("Format", "JSON");
        publicParams.put("Version", "2017-03-21");
        publicParams.put("AccessKeyId", accessKeyId);
        publicParams.put("SignatureMethod", "HMAC-SHA1");
        publicParams.put("Timestamp", generateTimestamp());
        publicParams.put("SignatureVersion", "1.0");
        publicParams.put("SignatureNonce", generateRandom());
        if (securityToken != null && securityToken.length() > 0) {
            publicParams.put("SecurityToken", securityToken);
        }
        return publicParams;
    }

    /**
     * 生成OpenAPI地址
     * @param params 请求入参
     * @return 返回请求url
     * @throws Exception 异常
     */
    public static String generateOpenAPIURL(Map<String, String> params, String accessKeyId,
        String accessKeySecret, String securityToken) {
        Map<String, String> publicParams = generatePublicParamters(accessKeyId, securityToken);
        return generateURL(VOD_DOMAIN, HTTP_METHOD, publicParams, params, accessKeySecret);
    }

    /**
     * @param domain        请求地址
     * @param httpMethod    HTTP请求方式GET，POST等
     * @param publicParams  公共参数
     * @param privateParams 接口的私有参数
     * @return 最后的url
     */
    private static String generateURL(String domain, String httpMethod, Map<String, String> publicParams,
                                      Map<String, String> privateParams, String accessKeySecret) {
        List<String> allEncodeParams = getAllParams(publicParams, privateParams);
        String cqsString = getCQS(allEncodeParams);
        out("CanonicalizedQueryString = " + cqsString);
        String stringToSign = httpMethod + "&" + percentEncode("/") + "&" + percentEncode(cqsString);
        out("StringtoSign = " + stringToSign);
        String signature = hmacSHA1Signature(accessKeySecret, stringToSign);
        out("Signature = " + signature);
        return domain + "?" + cqsString + "&" + percentEncode("Signature") + "=" + percentEncode(signature);
    }

    private static List<String> getAllParams(Map<String, String> publicParams, Map<String, String> privateParams) {
        List<String> encodeParams = new ArrayList<>();
        encodeParams.addAll(getParams(publicParams));
        encodeParams.addAll(getParams(privateParams));
        return encodeParams;
    }

    private static List<String> getParams(Map<String, String> publicParams) {
        List<String> encodeParams = new ArrayList<>();
        if (publicParams != null) {
            for (String key : publicParams.keySet()) {
                String value = publicParams.get(key);
                //将参数和值都urlEncode一下。
                String encodeKey = percentEncode(key);
                String encodeVal = percentEncode(value);
                encodeParams.add(encodeKey + "=" + encodeVal);
            }
        }
        return encodeParams;
    }

    /**
     * 参数urlEncode
     *
     * @param value 待url转码的数据
     * @return 转码结果
     */
    private static String percentEncode(String value) {
        try {
            String urlEncodeOrignStr = URLEncoder.encode(value, "UTF-8");
            String plusReplaced = urlEncodeOrignStr.replace("+", "%20");
            String starReplaced = plusReplaced.replace("*", "%2A");
            return starReplaced.replace("%7E", "~");
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }
        return value;
    }

    /**
     * 获取CQS 的字符串
     *
     * @param allParams 入参
     * @return 返回拼接好的get参数
     */
    private static String getCQS(List<String> allParams) {
        ParamsComparator paramsComparator = new ParamsComparator();
        Collections.sort(allParams, paramsComparator);
        String cqString = "";
        for (int i = 0; i < allParams.size(); i++) {
            cqString += allParams.get(i);
            if (i != allParams.size() - 1) {
                cqString += "&";
            }
        }

        return cqString;
    }

    private static class ParamsComparator implements Comparator<String> {
        @Override
        public int compare(String lhs, String rhs) {
            return lhs.compareTo(rhs);
        }
    }

    private static String hmacSHA1Signature(String accessKeySecret, String stringtoSign) {
        try {
            String key = accessKeySecret + "&";
            try {
                SecretKeySpec signKey = new SecretKeySpec(key.getBytes(), HMAC_SHA1_ALGORITHM);
                Mac mac = Mac.getInstance(HMAC_SHA1_ALGORITHM);
                mac.init(signKey);
                byte[] rawHmac = mac.doFinal(stringtoSign.getBytes());
                //按照Base64 编码规则把上面的 HMAC 值编码成字符串，即得到签名值（Signature）
                return new BASE64Encoder().encode(rawHmac);
            } catch (Exception e) {
                throw new SignatureException("Failed to generate HMAC : " + e.getMessage());
            }
        } catch (SignatureException e) {
            e.printStackTrace();
        }
        return "";
    }

    /**
     * 生成随机数
     *
     * @return 返回随机数字符串
     */
    private static String generateRandom() {
        return UUID.randomUUID().toString();
    }

    /**
     * 生成当前UTC时间戳
     *
     * @return 返回时间戳字符串
     */
    private static String generateTimestamp() {
        Date date = new Date(System.currentTimeMillis());
        SimpleDateFormat df = new SimpleDateFormat(ISO8601_DATE_FORMAT);
        df.setTimeZone(new SimpleTimeZone(0, "GMT"));
        return df.format(date);
    }

    private static void out(String newLine) {
        LOG.log(Level.INFO, newLine);
    }

}
