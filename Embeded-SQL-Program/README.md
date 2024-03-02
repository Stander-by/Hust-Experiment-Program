# 数据库设计

## 环境配置和初始化

为了创建一个使用C++中的嵌入式SQL提供数据库查询功能的学生管理系统，可以按照以下步骤操作：

1.  在Visual Studio 2019中新建一个空项目，选择Debug配置和X64平台。
2.  打开项目属性，转到C/C++ \> 常规 \> 附加包含目录。添加下载的MySQL源代码中的include目录。
3.  转到链接器 \> 常规 \> 附加库目录，添加下载的MySQL源代码中的lib目录。
4.  转到链接器 \> 输入 \> 附加依赖项，添加MySQL源代码中的libmysql.lib文件。添加完成后，将libmysql.lib文件拷贝到项目目录下。
5.  使用MySQL C++ API中的mysql_init和mysql_real_connect函数初始化连接句柄并连接到数据库。

在添加了必要的文件之后，就可以使用MySQL C++ API在C++中编写嵌入式SQL代码连接并查询数据库。还可以使用API执行其他操作，例如在数据库中插入、更新和删除数据，关键代码如下图所示。

![](media/bc9738759df1b2ebf44b0f677c2e9cfd.png)

## 功能实现

### 新生入学信息增加，学生信息修改

![](media/f313f0f8fe705a0ae43ef93c969ed9dd.png)

![](media/a6a3429e3b9d2076c219429de22fbc64.png)

### 课程信息维护（增加新课程，修改课程信息，删除没有选课的课程信息）

![](media/d604fafebaf5e07a1bbda7cd30a4c56f.png)

### 录入学生成绩，修改学生成绩

![](media/edc960ea081a27877378a1ffb5fb27fe.png)

![](media/704467a2ebf87038f9e8c6bf0b4f4a2b.png)

### 按系统计学生的平均成绩、最好成绩、最差成绩、优秀率、不及格人数；

![](media/1b9c1dff625a59a5fa375da5d7638b0f.png)

![](media/35eb027fcf3fd86cf267a961225c0923.png)

![](media/ec395338c6b2fef44f3edc9cb33e9e65.png)

![](media/d9ed6b41376ed1fa7ed3f0d0686f7ac5.png)

### 按系对学生成绩进行排名，同时显示出学生、课程和成绩信息

![](media/c4f32750784ad354cdee31138bf0cacf.png)

### 输入学号，显示该学生的基本信息和选课信息

![](media/1810033c5e583aff5209b7a4b0864a13.png)
