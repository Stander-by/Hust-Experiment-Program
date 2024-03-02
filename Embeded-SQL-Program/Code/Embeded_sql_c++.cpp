#include<winsock.h>//注意顺序，要放在mysql.h前
#include<iostream>
#include<stdio.h>
#include<string.h>
#include<mysql.h>
using namespace std;


MYSQL conn;   //连接句柄
char column_name[32][128];   //存储列字段名的二维数组
char chg_situation[128];//修改或删除条件（where子句）
int cnt = 0;

void show_menu() //总体的菜单显示
{
    printf("\n\n----------Welcome to Student-Course Management System!------------\n");
    printf("-------------The system provides the services below.--------------\n");
    printf("-------1.op student information(modify TABLE STUDENT)-------\n");
    printf("-------2.op course information(modify TABLE COURSE)---------\n");
    printf("-------3.op student grades information(modify TABLE SC)-----\n");
    printf("-------4.Search student grades------------------------------------\n");
    printf("-------5.Search student grades ranking----------------------------\n");
    printf("-------6.Search student primary information and course-selecting information\n");
    printf("-------0.Exit Student-Course Management System.-------------------\n");
    printf("\n");
    return;
}

void service1_menu()  //第一个功能的菜单（修改student表）
{
    printf("\n\n");
    printf("--------Welcome to op Student Information Service!----------\n");
    printf("---------------What you can do are listed below.------------------\n");
    printf("----------1.insert a new student to TABLE STUDENT-----------------\n");
    printf("----------2.update student information----------------------------\n");
    printf("----------0.exit the service.-------------------------------------\n");
    return;
}

void service2_menu() //第二个功能的菜单（修改course表）
{
    printf("\n\n");
    printf("---------Welcome to op Course Information Service!----------\n");
    printf("---------------What you can do are listed below.------------------\n");
    printf("----------1.insert a new course to TABLE COURSE-------------------\n");
    printf("----------2.update course information-----------------------------\n");
    printf("----------3.delete course that not to be selected by student------\n");
    printf("----------0.exit the service.-------------------------------------\n");
    return;
}

void service3_menu()//第三个功能的菜单（修改sc表）
{
    printf("\n\n");
    printf("------Welcome to op Student Grades Information Service!-----\n");
    printf("---------------What you can do are listed below.------------------\n");
    printf("----------1.insert a new student grade to TABLE SC----------------\n");
    printf("----------2.update grade information------------------------------\n");
    printf("----------0.exit the service.-------------------------------------\n");
    return;
}

void service4_menu()//第四个功能的菜单（查询学生成绩情况）
{
    printf("\n\n");
    printf("------------Welcome to Student Grades Search Service!-------------\n");
    printf("---------------What you can do are listed below.------------------\n");
    printf("----------1.search the average grade------------------------------\n");
    printf("----------2.search the best grade---------------------------------\n");
    printf("----------3.search the worst grade--------------------------------\n");
    printf("----------4.search the percent of grade not lower than 90---------\n");
    printf("----------5.search the number of grade lower than 60--------------\n");
    printf("----------0.exit the service.-------------------------------------\n");
    return;
}

void service5_menu()//第五个功能的菜单（查询学生成绩排名）
{
    printf("\n\n");
    printf("------------Welcome to Grade Ranking Search Service!--------------\n");
}

void service6_menu()//第六个功能的菜单（查询学生基本信息和选课信息）
{
    printf("\n\n");
    printf("-------Welcome to Student Primary Information Search Service------\n");
}

void get_sql_sentence() //获得用户自定义的sql语句
{
    int i = 0;
    char ch = '3';

    memset(chg_situation, 0, sizeof(chg_situation));

    ch = getchar();
    while (ch == '\n' || ch == '\t' || ch == ' ') //去除前导\n\t和空格的影响
    {
        ch = getchar();
    }
    while (ch != '\n') //去除换行符的影响
    {
        chg_situation[i] = ch;
        i++;
        ch = getchar();
    }
    chg_situation[i] = '\0';
    return;
}

void op_student() //1.维护student表
{
    int ch; //选择序号
    char new_sno[16]; //学号
    char new_sname[21]; //姓名
    char new_sex[9]; //性别
    int new_sage = 0; //年龄
    char new_sdept[21]; //专业
    char new_scholarship[9]; //奖学金情况

    char chg_column[15]; //需要修改的属性名
    char chg_value_str[21]; //修改的属性值（字符串）
    int chg_value_int = 0;  //修改的属性值（整数）
    long affect = 0;
    char sql[512]; //sql语句

    service1_menu(); //先打印功能菜单
    printf("\nPlease input your option:\n");
    scanf("%d", &ch);

    while (ch)
    {
        switch (ch)
        {
        case 1: //新增学生信息，限制一次新增一条
        {
            memset(sql, 0, sizeof(sql)); //sql字符串清空
            memset(new_sno, 0, sizeof(new_sno));
            memset(new_sname, 0, sizeof(new_sname));
            memset(new_sex, 0, sizeof(new_sex));
            memset(new_sdept, 0, sizeof(new_sdept));
            memset(new_scholarship, 0, sizeof(new_scholarship));
            //录入新加的学生的各项属性
            cout << "Please input new student sno : \n";
            cin >> new_sno;
            cout << "Please input new student sname : \n";
            cin >> new_sname;
            cout << "Please input new student sex : \n";
            cin >> new_sex;
            cout << "Please input new student sage : \n";
            cin >> new_sage;
            cout << "Please input new student sdept : \n";
            cin >> new_sdept;
            cout << "Please input new student scholarship : \n";
            cin >> new_scholarship;
            sprintf(sql, "INSERT INTO student (sno,sname,ssex,sage,sdept,scholarship) VALUES ('%s','%s','%s',%d,'%s','%s')",
                new_sno, new_sname, new_sex, new_sage, new_sdept, new_scholarship);  //填充sql语句

            if (mysql_query(&conn, sql)) //插入失败
            {
                printf("INSERT ERROR: %s", mysql_error(&conn)); //打印错误信息
                return;
            }
            affect = (long)mysql_affected_rows(&conn);
            if (affect > 1)
            {
                printf("\nINSERT new student information successfully! %ld rows are affected.\n", affect);
            }
            else
            {
                printf("\nINSERT new student information successfully! %ld row is affected.\n", affect);
            }

            break;
        }
        case 2://修改学生信息，由用户自定义更新条件，一次只能修改一个属性值
        {
            memset(sql, 0, sizeof(sql)); //sql字符串清空
            memset(chg_column, 0, sizeof(chg_column));
            memset(chg_value_str, 0, sizeof(chg_value_str));
            memset(chg_situation, 0, sizeof(chg_situation));
            printf("Please input the column you want to change--sno,sname,ssex,sage,sdept,scholarship:\n");
            scanf("%s", chg_column);
            printf("Please input the value you want to change into %s:\n", chg_column);
            if (strcmp(chg_column, "sage") == 0) //修改整数值
            {
                scanf("%d", &chg_value_int);
            }
            else //修改字符串
            {
                scanf("%s", chg_value_str);
            }

            printf("Please input the change situation(followed by where):\n");
            get_sql_sentence(); //录入where子句

            //拼接sql语句
            if (strcmp(chg_column, "sage") == 0)
            {
                sprintf(sql, "UPDATE student SET sage=%d WHERE %s", chg_value_int, chg_situation);
            }
            else
            {
                sprintf(sql, "UPDATE student SET %s=\'%s\' WHERE %s", chg_column, chg_value_str, chg_situation);
            }

            if (mysql_query(&conn, sql)) //更新失败
            {
                printf("UPDATE ERROR: %s", mysql_error(&conn)); //打印错误信息
                return;
            }
            affect = (long)mysql_affected_rows(&conn);
            if (affect > 1)
            {
                printf("\nUPDATE new student information successfully! %ld rows are affected.\n", affect);
            }
            else
            {
                printf("\nUPDATE new student information successfully! %ld row is affected.\n", affect);
            }
            break;
        }
        case 0:
            break;
        default:
            break;
        }
        service1_menu(); //先打印功能菜单
        printf("\nPlease input your option:\n");
        scanf("%d", &ch);
    }

    printf("\nWelcome to use the service next time!\n\n");
    return;
}

void op_course()  //2.维护course表
{
    int ch; //选择序号
    int flag; //标志，是否有先修课
    char cpno_flag[5]; //先修课选择标志
    char new_cno[3]; //课程号
    char new_cname[10]; //课程名
    char new_cpno[10]; //先修课
    char set_off[] = "SET FOREIGN_KEY_CHECKS = 0";
    char set_up[] = "SET FOREIGN_KEY_CHECKS = 1";
    int new_credit;  //学分

    char chg_column[15]; //需要修改的属性名
    char chg_value_str[15]; //修改的属性值（字符串）
    int chg_value_int = 0;  //修改的属性值（整数）
    long affect = 0;

    char sql[512]; //sql语句

    service2_menu(); //显示功能菜单
    printf("\nPlease input your option:\n");
    scanf("%d", &ch);

    while (ch)
    {
        switch (ch)
        {
        case 1:  //添加新课程
        {
            memset(sql, 0, sizeof(sql));
            memset(new_cno, 0, sizeof(new_cno));
            memset(new_cname, 0, sizeof(new_cname));
            memset(new_cpno, 0, sizeof(new_cpno));
            memset(cpno_flag, 0, sizeof(cpno_flag));

            printf("Please input new course cno:\n");
            scanf("%s", new_cno);
            printf("Please input new course cname:\n");
            scanf("%s", new_cname);
            printf("The new course has cpno or not? Please choose(input yes or no):\n");
            scanf("%s", cpno_flag);
            if (strcmp(cpno_flag, "yes") == 0)
            {
                flag = 1;
                printf("Please input cpno of new course:\n");
                scanf("%s", new_cpno);
            }
            else  //不输入yes一律视为没有先修课
            {
                printf("The new course has no cpno.\n");
                flag = 0;
            }
            printf("Please input new course credit:\n");
            scanf("%d", &new_credit);

            if (flag)
            {
                sprintf(sql, "INSERT INTO course (cno,cname,cpno,ccredit) VALUES (\'%s\',\'%s\',\'%s\',%d)", new_cno, new_cname, new_cpno, new_credit);
            }
            else
            {
                sprintf(sql, "INSERT INTO course (cno,cname,ccredit) VALUES (\'%s\',\'%s\',%d)", new_cno, new_cname, new_credit);
            }

            if (mysql_query(&conn, sql))
            {
                printf("INSERT ERROR: %s", mysql_error(&conn)); //打印错误信息
                return;
            }
            affect = (long)mysql_affected_rows(&conn);
            if (affect > 1)
            {
                printf("\nINSERT new course information successfully! %ld rows are affected.\n", affect);
            }
            else
            {
                printf("\nINSERT new course information successfully! %ld row is affected.\n", affect);
            }
            break;
        }
        case 2: //更新已有课程信息
        {
            memset(sql, 0, sizeof(sql));
            memset(chg_column, 0, sizeof(chg_column));
            memset(chg_value_str, 0, sizeof(chg_value_str));
            memset(chg_situation, 0, sizeof(chg_situation));
            printf("Please input the column you want to change--cno,cname,cpno,ccredit:\n");
            scanf("%s", chg_column);
            printf("Please input the value you want to change into %s:\n", chg_column);

            if (strcmp(chg_column, "ccredit") == 0) //修改整数值
            {
                scanf("%d", &chg_value_int);
            }
            else //修改字符串
            {
                scanf("%s", chg_value_str);
            }

            printf("Please input the change situation(followed by where):\n");
            get_sql_sentence(); //录入where子句

            if (strcmp(chg_column, "ccredit") == 0)
            {
                sprintf(sql, "UPDATE course SET ccredit=%d WHERE %s", chg_value_int, chg_situation);
            }
            else
            {
                sprintf(sql, "UPDATE course SET %s=\'%s\' WHERE %s", chg_column, chg_value_str, chg_situation);
            }

            if (mysql_query(&conn, sql)) //更新失败
            {
                printf("UPDATE ERROR: %s", mysql_error(&conn)); //打印错误信息
                return;
            }
            affect = (long)mysql_affected_rows(&conn);
            if (affect > 1)
            {
                printf("\nUPDATE new course information successfully! %ld rows are affected.\n", affect);
            }
            else
            {
                printf("\nUPDATE new course information successfully! %ld row is affected.\n", affect);
            }
            break;
        }
        case 3: //删除没有选课的课程信息
        {
            printf("Now all courses that are not to be selected by student will be deleted!\n");

            if (mysql_real_query(&conn, set_off, strlen(set_off)))   //删除前撤销外码检查
            {
                printf("SET ERROR: %s", mysql_error(&conn)); //打印错误信息
                return;
            }

            strcpy(sql, "DELETE FROM course WHERE cno NOT IN (SELECT DISTINCT cno FROM sc)");
            if (mysql_query(&conn, sql)) //更新失败
            {
                printf("DELETE ERROR: %s", mysql_error(&conn)); //打印错误信息
                return;
            }
            affect = (long)mysql_affected_rows(&conn);
            if (affect > 1)
            {
                printf("\nDELETE new course information successfully! %ld rows are affected.\n", affect);
            }
            else
            {
                printf("\nDELETE new course information successfully! %ld row is affected.\n", affect);
            }

            if (mysql_real_query(&conn, set_up, strlen(set_up))) //删除后恢复外码检查
            {
                printf("SET ERROR: %s", mysql_error(&conn)); //打印错误信息
                return;
            }
            break;
        }
        case 0:
            break;
        default:
            break;
        }
        service2_menu(); //显示功能菜单
        printf("\nPlease input your option:\n");
        scanf("%d", &ch);
    }
    printf("\nWelcome to use the service next time!\n\n");
    return;
}

void op_sc() //3.管理学生成绩（sc表）
{
    int ch;
    char new_sno[15];
    char new_cno[3];
    int new_grade;  //新增的成绩和更新已有的成绩使用同一个变量，因为sc表的更新只涉及成绩一项
    long affect = 0;

    char sql[512]; //sql语句

    service3_menu();
    printf("\nPlease input your option:\n");
    scanf("%d", &ch);

    while (ch)
    {
        switch (ch)
        {
        case 1: //录入新成绩
        {
            memset(sql, 0, sizeof(sql));
            memset(new_sno, 0, sizeof(new_sno));
            memset(new_cno, 0, sizeof(new_cno));

            //录入新的选课信息
            printf("Please input new sc sno:\n");
            scanf("%s", new_sno);
            printf("Please input new sc cno:\n");
            scanf("%s", new_cno);
            printf("Please input new sc grade:\n");
            scanf("%d", &new_grade);

            sprintf(sql, "INSERT INTO sc (sno,cno,grade) VALUES (\'%s\',\'%s\',%d)", new_sno, new_cno, new_grade);
            if (mysql_query(&conn, sql))
            {
                printf("INSERT ERROR: %s", mysql_error(&conn)); //打印错误信息
                return;
            }
            affect = (long)mysql_affected_rows(&conn);
            if (affect > 1)
            {
                printf("\nINSERT new sc information successfully! %ld rows are affected.\n", affect);
            }
            else
            {
                printf("\nINSERT new sc information successfully! %ld row is affected.\n", affect);
            }
            break;
        }
        case 2:  //修改已有的成绩,每次仅限制修改一条记录
        {
            memset(sql, 0, sizeof(sql));

            printf("Please set the new grade:\n");
            scanf("%d", &new_grade);
            printf("Please input the sno of student whose grade be modified:\n");
            scanf("%s", new_sno);
            printf("Please input the cno of student whose grade be modified:\n");
            scanf("%s", new_cno);

            sprintf(sql, "UPDATE sc SET grade=%d WHERE sno=\'%s\' and cno=\'%s\'", new_grade, new_sno, new_cno);

            if (mysql_query(&conn, sql)) //更新失败
            {
                printf("UPDATE ERROR: %s", mysql_error(&conn)); //打印错误信息
                return;
            }
            affect = (long)mysql_affected_rows(&conn);
            if (affect > 1)
            {
                printf("\nUPDATE new sc information successfully! %ld rows are affected.\n", affect);
            }
            else
            {
                printf("\nUPDATE new sc information successfully! %ld row is affected.\n", affect);
            }
            break;
        }
        case 0:
            break;
        default:
            break;
        }
        service3_menu();
        printf("\nPlease input your option:\n");
        scanf("%d", &ch);
    }
    printf("\nWelcome to use the service next time!\n\n");
    return;
}

bool show_select_set(char* sqlstmt, int check_num) //打印select的结果集,参数为待执行的sql语句,check_num为当前查询号
{
    int i, j;
    int num_field, num_row; //结果集的列数和行数
    MYSQL_RES* res_set = NULL;  //结果集
    MYSQL_ROW row = NULL;  //行字段
    MYSQL_FIELD* column = NULL;  //列字段

    memset(column_name, 0, sizeof(column_name)); //清空列字段字符串数组

    if (mysql_query(&conn, sqlstmt)) //查询出错
    {
        printf("SELECT ERROR: %s\n", mysql_error(&conn)); //打印错误信息
        return false;
    }
    res_set = mysql_store_result(&conn); //获取结果集，存储在变量res_set中
    if (!res_set) //返回的结果集无效
    {
        printf("Could not get valid result,ERROR:%s\n", mysql_error(&conn));
        return false;
    }
    num_field = mysql_num_fields(res_set); //获取结果列数
    num_row = mysql_num_rows(res_set); //获取结果行数

    for (i = 0; i < num_field; ++i)
    {
        column = mysql_fetch_field(res_set);
        printf("%-9s\t", column->name);  //打印列字段名结果
    }
    printf("\n");

    while (row = mysql_fetch_row(res_set))
    {
        for (i = 0; i < num_field; ++i)
        {
            if (row[i])
            {
                if ((check_num == 1 && i == 1) || (check_num == 4 && i == 3)) //处理结果字段为浮点数的情况
                {
                    printf("%-9.2f\t", atof(row[i]));
                }
                else if ((check_num == 2 && i == 5) || (check_num == 3 && i == 5) || (check_num == 4 && i == 1) || (check_num == 4 && i == 2) || (check_num == 5 && i == 1)
                    || (check_num == 6 && i == 3) || (check_num == 6 && i == 7))
                {
                    //处理结果字段为整型数的情况
                    printf("%-9d\t", atoi(row[i]));
                }
                else
                {
                    printf("%-9s\t", row[i]);
                }
            }
            else
            {
                printf("%-9s\t", "NULL");
            }
        }
        printf("\n");
    }
    mysql_free_result(res_set); //单次查询结束后释放结果集
    return true;
}

void grade_search() //4.查询学生成绩
{
    int ch;
    bool flag;
    char sql[512]; //sql语句

    service4_menu(); //显示菜单
    printf("Please input a check number:\n");
    scanf("%d", &ch);

    while (ch)
    {
        switch (ch)
        {
        case 1: //查平均分
        {
            printf("\nSearch the Average Grade!\n");
            strcpy(sql, "SELECT sdept,AVG(grade) AS avg_grade FROM student LEFT JOIN sc ON (student.sno=sc.sno) GROUP BY sdept"); //查询语句
            flag = show_select_set(sql, 1);
            if (!flag)
                return;
            break;
        }
        case 2: //查最高分
        {
            printf("\nSearch the Maximum Grade!\n");
            strcpy(sql, "SELECT sdept,student.sno,sname,course.cno,cname,grade FROM student, sc,course,(SELECT sdept,MAX(grade) FROM student LEFT JOIN sc ON (student.sno=sc.sno) GROUP BY sdept) AS max_table(m_dept,m_grade) WHERE sdept=m_dept AND student.sno=sc.sno AND grade=m_grade AND course.cno=sc.cno");
            flag = show_select_set(sql, 2);
            if (!flag)
                return;
            break;
        }
        case 3: //查最低分
        {
            printf("\nSearch the Minimum Grade!\n");
            strcpy(sql, "SELECT sdept,student.sno,sname,course.cno,cname,grade FROM student, sc,course,(SELECT sdept,MIN(grade) FROM student LEFT JOIN sc ON (student.sno=sc.sno) GROUP BY sdept) AS max_table(m_dept,m_grade) WHERE sdept=m_dept AND student.sno=sc.sno AND grade=m_grade AND course.cno=sc.cno");
            flag = show_select_set(sql, 3);
            if (!flag)
                return;
            break;
        }
        case 4: //查优秀率
        {
            printf("\nSearch the Great Grade Percent!\n");
            strcpy(sql, "SELECT sdept,COUNT(CASE WHEN student.sno=sc.sno AND grade>=90 THEN 1 ELSE NULL END) AS great_num,COUNT(CASE WHEN student.sno=sc.sno THEN 1 ELSE NULL END) AS all_num, COUNT(CASE WHEN student.sno=sc.sno AND grade>=90 THEN 1 ELSE NULL END)/COUNT(CASE WHEN student.sno=sc.sno THEN 1 ELSE NULL END) AS percent FROM student LEFT JOIN sc ON student.sno=sc.sno GROUP BY sdept");
            //strcpy(sql, "SELECT sdept,COUNT(CASE WHEN student.sno=sc.sno AND grade>=90 THEN 1 ELSE NULL END) AS great_num,COUNT(CASE WHEN student.sno=sc.sno THEN 1 ELSE NULL END) AS all_num, COUNT(CASE WHEN student.sno=sc.sno AND grade>=90 THEN 1 ELSE NULL END)/COUNT(CASE WHEN student.sno=sc.sno THEN 1 ELSE NULL END) AS great_percent FROM student,sc GROUP BY sdept");
            flag = show_select_set(sql, 4);
            if (!flag)
                return;
            break;
        }
        case 5: //查不及格人数
        {
            printf("\nSearch the Number of Student less than 60!\n");
            strcpy(sql, "SELECT sdept,COUNT(CASE WHEN student.sno=under_60.usno THEN 1 ELSE NULL END) AS under_60_num FROM student LEFT JOIN (SELECT DISTINCT student.sno FROM student,sc WHERE student.sno=sc.sno AND grade<60) AS under_60(usno) ON student.sno=under_60.usno GROUP BY sdept");
            //strcpy(sql, "SELECT sdept,count(CASE WHEN student.sno=sc.sno AND grade<60 THEN 1 ELSE NULL END) AS num_of_grade_less_than_60 FROM student,sc GROUP BY sdept");
            flag = show_select_set(sql, 5);
            if (!flag)
                return;
            break;
        }
        case 0:
            break;
        default:
            break;
        }
        service4_menu(); //显示菜单
        printf("Please input a check number:\n");
        scanf("%d", &ch);
    }
    printf("\nWelcome to use the service next time!\n\n");
    return;
}

void grade_ranking() //5.成绩排名查询
{
    MYSQL_RES* res_set = NULL;  //结果集
    MYSQL_ROW row = NULL, last_row = NULL; //行字段
    MYSQL_FIELD* column = NULL;  //列字段
    char sql[512]; //sql语句
    int num_field, num_row;
    int i, j;
    int rank = 1; //排名，初始值为1
    int count = 1;
    service5_menu(); //显示菜单
    memset(column_name, 0, sizeof(column_name)); //清空列字段字符串数组

    //录入查询语句
    strcpy(sql, "SELECT sdept,student.sno,sname,course.cno,cname,grade FROM student,course,sc WHERE student.sno=sc.sno AND course.cno=sc.cno ORDER BY sdept DESC,cno ASC,grade DESC");
    //处理查询结果
    if (mysql_query(&conn, sql)) //查询出错
    {
        printf("SELECT ERROR: %s\n", mysql_error(&conn)); //打印错误信息
        return;
    }
    res_set = mysql_store_result(&conn); //获取结果集，存储在变量res_set中
    if (!res_set) //返回的结果集无效
    {
        printf("Could not get valid result,ERROR:%s\n", mysql_error(&conn));
        return;
    }
    num_field = mysql_num_fields(res_set); //获取结果列数
    num_row = mysql_num_rows(res_set); //获取结果行数

    for (i = 0; i < num_field; ++i)
    {
        strcpy(column_name[i], mysql_fetch_field(res_set)->name); //存储列字段名,使用name，包含了设置别名的情况
    }

    printf("Grade Ranking results are listed below:\n");

    printf("%-9s\t", "ranking"); //排名字段
    for (i = 0; i < num_field; ++i)
    {
        printf("%-9s\t", column_name[i]);  //打印列名
    }
    printf("\n");

    while (row = mysql_fetch_row(res_set))
    {
        if (count == 1) //第一行
        {
            printf("%-9d\t", 1); //一定是第一名
        }
        else  //后面的行
        {
            if (strcmp(row[0], last_row[0]))  //和上一个元组的专业不同
            {
                rank = 1;
                printf("%-9d\t", 1);
            }
            else
            {
                rank++;
                printf("%-9d\t", rank);
            }
        }
        for (i = 0; i < num_field; ++i)
        {
            if (row[i])  //不为空值
            {
                if (i == 5)
                {
                    printf("%-9d\t", atoi(row[i]));
                }
                else
                {
                    printf("%-9s\t", row[i]);
                }
            }
            else
            {
                printf("%-9s\t", "NULL");
            }
        }
        printf("\n");
        last_row = row;
        count++;
    }
    printf("\nWelcome to use the service next time!\n\n");
    mysql_free_result(res_set); //单次查询结束后释放结果集
    return;
}

void show_stu_info()  //6.学生基本信息查询
{
    bool flag;
    char sql[512];
    service6_menu();//显示菜单
    printf("\nSearch the Based Information and Course-Selecting Results of Student!\n");
    strcpy(sql, "SELECT sno1,sname1,ssex1,sage1,sdept1,cno1,cname,grade1,scholarship1 FROM (SELECT student.sno,sname,ssex,sage,sdept,sc.cno,grade,scholarship FROM student LEFT JOIN sc ON student.sno=sc.sno) AS base1(sno1,sname1,ssex1,sage1,sdept1,cno1,grade1,scholarship1) LEFT JOIN course ON base1.cno1=course.cno");
    flag = show_select_set(sql, 6);
    if (!flag)
        return;
    printf("\nWelcome to use the service next time!\n\n");
    return;
}

int main() {
    int op; //记录选择功能结果
    mysql_init(&conn);
    cout << "Please enter the name of the database you want to use:\n";
    char db_name[128];
    fgets(db_name, 128, stdin);
    sscanf(db_name, "%s", db_name);
    if (!mysql_real_connect(&conn, "localhost", "root", "hust", db_name, 3306, NULL, 0))
    {
        cerr << "Failed to connect to database " << db_name << "! Error: " << mysql_error(&conn) << "\n\n";
        return 0;
    }
    cout << "Successfully connected to database " << db_name << "!\n\n";

    if (mysql_set_character_set(&conn, "gbk"))
    {
        cerr << "ERROR when set character_set:" << mysql_error(&conn);
    }
    show_menu();
    cout<<"Please input your option:"<<endl;
    scanf("%d", &op);  //记录选择结果
    
    while (op)
    {
        if(op==1) op_student();
        else if(op==2) op_course();
        else if(op==3) op_sc();
        else if(op==4) grade_search();
        else if(op==5) grade_ranking();
        else if(op==6) show_stu_info();
        else break;
        show_menu();
        cout<<"\nPlease input your option:\n";
        scanf("%d", &op);
        cnt++;
    }
    cout<<"\nWelcome to use Student-Course Management System next time!\n";
    mysql_close(&conn);
    cout<<"\nPress any key to exit!\n";
    system("pause");
    return 0;
}
