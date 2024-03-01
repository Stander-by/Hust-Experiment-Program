#include <linux/module.h>
#include <linux/fs.h>
#include <linux/uaccess.h>
#include <linux/init.h>
#include <linux/miscdevice.h>

#define NAME "code2"
MODULE_LICENSE("GPL");

static struct device *mydemodrv_device;
static int a=0,b=0;

static int demodrv_open(struct inode *inode, struct file *file)
{
	int major = MAJOR(inode->i_rdev);
	int minor = MINOR(inode->i_rdev);
	printk("%s: major=%d, minor=%d\n", __func__, major, minor);
	return 0;
}

static int demodrv_release(struct inode *inode, struct file *file)
{
	return 0;
}

static ssize_t
demodrv_read(struct file *file, char __user *buf, size_t lbuf, loff_t *ppos)
{
	printk("%s: a+b=%d\n", __func__,a+b);
	return 0;
}

static ssize_t
demodrv_write(struct file *file, const char __user *buf, size_t count, loff_t *f_pos)
{
	if(count>64)
	{
		count = 64;
	}
 	char temp[64];
	if(copy_from_user(temp,buf,count))
	{
		return -EFAULT;
	}
	sscanf(temp, "%d%d",&a,&b);
	printk("%s: a=%d,b=%d\n", __func__,a,b);
	return count;
}

static const struct file_operations demodrv_fops = {
	.owner = THIS_MODULE,
	.open = demodrv_open,
	.release = demodrv_release,
	.read = demodrv_read,
	.write = demodrv_write
};

static struct miscdevice mydemodrv_misc_device = {
	.minor = MISC_DYNAMIC_MINOR,
	.name = NAME,
	.fops = &demodrv_fops,
};

static int __init code2_init(void)
{
	int ret;
	ret = misc_register(&mydemodrv_misc_device);
	if (ret) {
		printk("failed register code2 misc device\n");
		return ret;
	}
	mydemodrv_device = mydemodrv_misc_device.this_device;
	printk("succeeded register char device: %s\n", NAME);
	return 0;
}

static void __exit code2_exit(void)
{
	printk("removing device: %s\n", NAME);
	misc_deregister(&mydemodrv_misc_device);
}

module_init(code2_init);
module_exit(code2_exit);

