package com.wolfpeng.controller;

import java.io.IOException;
import java.net.URL;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.Scanner;
import java.util.TimeZone;

import javax.servlet.http.HttpServletRequest;
import com.aliyuncs.DefaultAcsClient;
import com.aliyuncs.exceptions.ClientException;
import com.aliyuncs.http.MethodType;
import com.aliyuncs.http.ProtocolType;
import com.aliyuncs.profile.DefaultProfile;
import com.aliyuncs.profile.IClientProfile;
import com.aliyuncs.sts.model.v20150401.AssumeRoleRequest;
import com.aliyuncs.sts.model.v20150401.AssumeRoleResponse;
import com.wolfpeng.util.OpenApiUtil;
import org.springframework.stereotype.Controller;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.RequestMapping;
import com.alibaba.fastjson.JSONObject;

/**
 * @author penghao
 * @date 2017/4/25
 * Copyright ? 2017年 wolfpeng. All rights reserved.
 */

@Controller("HomeIndex")
@RequestMapping("/aliyun")
public class Index {

    /**
     * 从访问控制 RAM后台获取的accessKeyId
     */
    // TODO: 2018/4/21 替换accessKeyID
    private static final String ACCESS_KEY_ID = "ACCESS_KEY_ID";
    /**
     * 从访问控制 RAM后台获取的accessKeySecret
     */
    // TODO: 2018/4/21 替换accessKeySecret
    private static final String ACCESS_KEY_SECRET = "ACCESS_KEY_SECRET";

    /**
     * 目前只有"cn-hangzhou"这个region可用, 不要使用填写其他region的值
     */
    private static final String REGION_CN_HANGZHOU = "cn-hangzhou";

    /**
     * 当前 STS API 版本
    */
    private static final String STS_API_VERSION = "2015-04-01";

    @RequestMapping(value = "/")
    public String index(HttpServletRequest request) {
        request.setAttribute("date", "handle index request new");
        return "index";
    }

    /**
     * 获取角色的请求
     * @param accessKeyId       accessKeyId
     * @param accessKeySecret   accessKeySecret
     * @param roleArn           roleArn
     * @param roleSessionName   roleSessionName
     * @param policy            policy
     * @param protocolType      protocolType
     * @return 请求返回的结果
     * @throws ClientException
     */
    private static AssumeRoleResponse assumeRole(String accessKeyId, String accessKeySecret,
                                                 String roleArn, String roleSessionName, String policy,
                                                 ProtocolType protocolType) throws ClientException {
        // 创建一个 Aliyun Acs Client, 用于发起 OpenAPI 请求
        IClientProfile profile = DefaultProfile.getProfile(REGION_CN_HANGZHOU, accessKeyId, accessKeySecret);
        DefaultAcsClient client = new DefaultAcsClient(profile);
        // 创建一个 AssumeRoleRequest 并设置请求参数
        final AssumeRoleRequest request = new AssumeRoleRequest();
        request.setVersion(STS_API_VERSION);
        request.setMethod(MethodType.POST);
        request.setProtocol(protocolType);
        request.setRoleArn(roleArn);
        request.setRoleSessionName(roleSessionName);
        request.setPolicy(policy);
        // 发起请求，并得到response
        final AssumeRoleResponse response = client.getAcsResponse(request);
        return response;
    }

    private static class RoleInfo {
        String roleSessionName;
        String roleArn;
    }

    /**
     * mock 通过userId获取对应权限的roleArn
     * @param userId  业务的用户ID
     * @return  返回角色信息
     */
    private RoleInfo mockGetRoleInfo(String userId) {
        RoleInfo roleInfo = new RoleInfo();
        roleInfo.roleSessionName = "123";
        //类似于 //"acs:ram::1462045446152495:role/testrule";
        // TODO: 2018/4/21 修改替换roleArn
        roleInfo.roleArn = "roleArn";
        return roleInfo;
    }

    /**
     * 请求临时token
     * @param request   请求入参
     * @return  对应的jsp
     */
    @RequestMapping(value = "/token")
    public String token(HttpServletRequest request) {
        String userId = request.getParameter("uid");
        RoleInfo roleInfo = mockGetRoleInfo(userId);
        ProtocolType protocolType = ProtocolType.HTTPS;
        String policy = null;

        JSONObject jsonObject = new JSONObject();
        try {
            final AssumeRoleResponse assumeRoleResponse = assumeRole(ACCESS_KEY_ID, ACCESS_KEY_SECRET,
                roleInfo.roleArn, roleInfo.roleSessionName, policy, protocolType);

            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
            sdf.setTimeZone(TimeZone.getTimeZone("GMT"));
            Date date = sdf.parse(assumeRoleResponse.getCredentials().getExpiration());

            jsonObject.put("token", assumeRoleResponse.getCredentials().getSecurityToken());
            jsonObject.put("expiration", date.getTime());
            jsonObject.put("accessKeyId", assumeRoleResponse.getCredentials().getAccessKeyId());
            jsonObject.put("accessKeySecret", assumeRoleResponse.getCredentials().getAccessKeySecret());
        } catch (ClientException e) {
            jsonObject.put("error", e.getErrMsg());
        } catch (ParseException e) {
            jsonObject.put("error", e.getMessage());
        }
        request.setAttribute("data", jsonObject.toString());
        return "token";
    }

    /**
     * 简单的get请求，用于请求OpenAPI
     * @param url OpenAPI的url
     * @return 返回请求的结果(jsonString)
     * @throws IOException
     */
    private static String httpGet(String url) throws IOException {
        @SuppressWarnings("resource")
        Scanner s = new Scanner(new URL(url).openStream(), "utf-8").useDelimiter("\\A");
        try {
            return s.hasNext() ? s.next() : null;
        } finally {
            s.close();
        }
    }

    /**
     * 请求获取视频列表
     * @param request 请求入参
     * @return videolist的jsp
     */
    @RequestMapping(value = "/videolist")
    public String videolist(HttpServletRequest request) {
        //组装openAPI参数
        Map<String, String> params = new HashMap<>(3);
        params.put("Action", "GetVideoList");
        params.put("Status", "Normal");
        String url = OpenApiUtil.generateOpenAPIURL(params, ACCESS_KEY_ID, ACCESS_KEY_SECRET, null);

        JSONObject jsonObject = new JSONObject();
        try {
            request.setAttribute("data", httpGet(url));
        } catch (IOException e) {
            jsonObject.put("error", e.getMessage());
            request.setAttribute("data", jsonObject.toString());
        }
        return "videolist";
    }

    /** 请求获取视频详情
     * @param request 请求入参
     * @return video的jsp
     */
    @RequestMapping(value = "/video")
    public String video(HttpServletRequest request) {
        String vid = request.getParameter("vid");
        if (StringUtils.isEmpty(vid)) {
            return "video";
        }
        //组装openAPI参数
        Map<String, String> params = new HashMap<>(2);
        params.put("Action", "GetVideoInfo");
        params.put("VideoId", request.getParameter("vid"));
        String url = OpenApiUtil.generateOpenAPIURL(params, ACCESS_KEY_ID, ACCESS_KEY_SECRET, null);

        JSONObject jsonObject = new JSONObject();
        try {
            request.setAttribute("data", httpGet(url));
        } catch (IOException e) {
            jsonObject.put("error", e.getMessage());
            request.setAttribute("data", jsonObject.toString());
        }
        return "video";
    }
}