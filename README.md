# IoT-message-generator
## 说明
使用CSV 文件生成批量消息,使用EC2 模拟AWS IoT Greengrass 产生消息,支持使用Cloudformation 一键部署.
## 部署方法
1. 上传Message_generator.yml 到AWS Cloudformation 平台创建,创建过程中需要指定名称,VPC,地址,Keypair等.
2. 创建完成后,待EC2 启动完成,拷贝需要的生成消息的CSV文件到 EC2的/shared/greengrass/buffer/ 目录下即可
3. 将Greengrass Lambda 挂载本地资源,选择LocalVolumeResourceData资源,选择只读访问权限.
   ![图 1](res/1630503862589.png)  


## 使用限制
1. 目前可以在以下区域使用,us-east-1,us-west-2,eu-west-1,eu-central-1,ap-northeast-1,ap-southeast-1,ap-southeast-2,其他区域自行复制AMI 解决
2. CSV 文件无需Header,以","分割
3. 文件可以手动拷贝,也可以自行修改Userdata 完成自动复制,例如在

```
sudo chown -R ggc_user:ggc_group /shared/greengrass/buffer
```
下方增加

```
sudo wget -cO - https://Someurl//iotdata.csv >/shared/greengrass/buffer/iotdata.csv 
```
## 代码说明
代码自动完成以下工作
1. 创建VPC资源
