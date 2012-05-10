#!/usr/bin/python

from PIL import Image
import sys, cStringIO, urllib, re
import MySQLdb, readability

# --/ readability authorization
token = readability.xauth('getassembly', 'CutXN5cHHAS8NxnPt3eq9au6hHfvUqcB', 'getassembly', 'assembly')
rdd = readability.oauth('getassembly', 'CutXN5cHHAS8NxnPt3eq9au6hHfvUqcB', token=token)

# --/ bookmark url
url = sys.argv[1]
print url

# --/ add to readability
b = rdd.add_bookmark(url)
a = rdd.get_article(b.article.id) 

print a.title
print a.content

# --/ article content
t = a.title
c = a.content
c = c.replace('<div>', '')
c = c.replace('</div>', '')

# --/ extract video
#--m = re.compile(r'<iframe src="http://www.youtube.com/embed/(.*?)".*?</iframe>').search(c)
#--vid = m.group(1)

# --/ extract image
m = re.compile(r'<img .*?src="(.*?)".*?>').search(c)
img_url = m.group(1)

# --/ open image & get size
img = Image.open(cStringIO.StringIO(urllib.urlopen(img_url).read()))
img_w, img_h = img.size
img_ratio = img_w / float(img_h)

print img.size
print img_ratio

conn = MySQLdb.connect (host="localhost", user="db41232_sn_usr", passwd="dope911t", db="assembly")
cursor = conn.cursor()




#-- http://techcrunch.com/2012/04/30/uk-high-court-isps-must-block-the-pirate-bay/



#--$ python
#-->>> import readability
#-->>> token = readability.xauth('getassembly', 'CutXN5cHHAS8NxnPt3eq9au6hHfvUqcB', 'getassembly', 'assembly')
#-->>> rdd = readability.oauth('getassembly', 'CutXN5cHHAS8NxnPt3eq9au6hHfvUqcB', token=token)

#-->>> rdd.add_bookmark('http://techcrunch.com/2012/04/30/google-paypal-ifeelgoods/')
#--<bookmark id="9161423" favorite="False" archive="False" read_percent="0.00">

#-->>> b = rdd.get_bookmark('9161423')
#-->>> print b.article.__dict__
#--{'domain': u'techcrunch.com', 'author': u'Josh Constine', 'url': u'http://techcrunch.com/2012/04/30/google-paypal-ifeelgoods/', 'short_url': None, 'title': u'Google / PayPay Sales Exec Tyler Hoffman Defects To Virtual Currency Rewards Startup ifeelgoods', 'excerpt': u'ifeelgoods has a brilliant idea \u2014 letting you earn Facebook Credits for ecommerce purchases or following a brand on Twitter \u2014 but now it has to convince big companies and shopping sites to adopt its&hellip;', 'word_count': 406, 'content': None, 'date_published': datetime.datetime(2012, 4, 30, 0, 0), 'next_page_href': None, 'processed': True, 'content_size': None, '_rdd': None, 'id': u'ftpboxlq'}

#-->>> a = rdd.get_article('ftpboxlq')
#-->>> print a.__dict__
#--{'domain': u'techcrunch.com', 'author': u'Josh Constine', 'url': u'http://techcrunch.com/2012/04/30/google-paypal-ifeelgoods/', 'short_url': u'http://rdd.me/ftpboxlq', 'title': u'Google / PayPay Sales Exec Tyler Hoffman Defects To Virtual Currency Rewards Startup ifeelgoods', 'excerpt': u'ifeelgoods has a brilliant idea \u2014 letting you earn Facebook Credits for ecommerce purchases or following a brand on Twitter \u2014 but now it has to convince big companies and shopping sites to adopt its&hellip;', 'word_count': 406, 'content': u'<div class="body-copy" score="11.25">\n\t\t\t\t\t\t\t\n\n\t\t\t\t\t\t\t<p><a href="http://www.ifeelgoods.com/" rel="nofollow">ifeelgoods</a> has a brilliant idea \u2014 letting you earn Facebook Credits for ecommerce purchases or following a brand on Twitter \u2014 but now it has to convince big companies and shopping sites to adopt its tech. That\u2019s why it\u2019s hired former Google Managing Director of Commerce Sales and leader of PayPal\u2019s\xa0enterprise sales team\xa0<a href="http://www.linkedin.com/in/tylerhoffman" rel="nofollow">Tyler Hoffman</a> to be its new Senior Vice President of Sales.</p>\n<p>Ifeelgoods is starting to snowball, as CEO Michael Amar says\xa092% of customers returning to ifeelgoods and increasing their budget by 250%. Of my years in tech, this is one of the most promising startups I\u2019ve seen. Because virtual currency is so cheap to distribute and is highly valued by some consumers, ifeelgoods could become a big disruptive force in how businesses acquire customers.</p>\n<p><a href="http://techcrunch.com/?attachment_id=543551" rel="wp-att-543551 attachment nofollow"><img src="http://tctechcrunch2011.files.wordpress.com/2012/04/50-free-credits-with-any-purchase-on-shoebuy.png?w=640" alt="" title="50-Free-Credits-with-Any-Purchase-on-Shoebuy" class="aligncenter size-full wp-image-543551"></a></p>\n<p>This is how the <a href="http://www.crunchbase.com/company/ifeelgoods" rel="nofollow">$8 million-funded ifeelgoods</a> microincentive <a href="http://techcrunch.com/2010/09/20/ifeelgoods/" rel="nofollow">model</a> works. The startup buys Facebook Credits from the social network in bulk. These Credits normally cost gamers $0.10 each, and are used to buy virtual goods, power-ups, and play time in social games, as well as music, movies, and other digital media. Possibly the world\u2019s most popular virtual currency, more and more people want Credits, but many don\u2019t want to pay for them because, well, they\u2019re just for fun.</p>\n<p>Ifeelgoods finds companies with specific actions they want people to take, and lets them incentivize these actions. So you could get 50 Credits for making a $50+ clothing purchase on Gap.com, 10 for installing a new Facebook game, 5 for signing up for Universal Pictures\u2019 email list, or 3 for following the Dallas Mavericks basketball team on Twitter.\xa0Once you\u2019ve completed an action, you approve the ifeelgoods Facebook app, and the Credits are deposited into your account.</p>\n<p><a href="http://techcrunch.com/?attachment_id=543553" rel="wp-att-543553 attachment nofollow"><img src="http://tctechcrunch2011.files.wordpress.com/2012/04/earn-free-credits.png?w=640" alt="" title="Earn-Free-Credits" class="aligncenter size-full wp-image-543553"></a></p>\n<p>Clients pay ifeelgoods for the Credits plus a fee. Walmart, Netflix, 1-800-Flowers, and Coca-Cola are a few more of its 70+ clients, but Hoffman is tasked with getting more brands on board. His 16 months at Google, seven years at PayPal, and three more doing sales for CNET should help.</p>\n<p>Here\u2019s a few reasons I believe in the model: distributing Credits is cheaper than mailing coupons, small incentives are more attractive than discounts since they don\u2019t expire can be spent anywhere that accepts Credits, they\u2019re viral since users get a chance to share news of being rewarded, and ads offering Credits get high click-through rates than those offering traditional discounts. Not everyone\u2019s willing to pay for social games and digital media. With ifeelgoods, they don\u2019t have to.</p>\n  \t\t\t\t\t\t\t\n\t\t\t\t\t\t\t\n\t\t\t\t\t\t\t\t\t\t\t\t\t</div>\n\t\t\t\t\t', 'date_published': datetime.datetime(2012, 4, 30, 0, 0), 'next_page_href': None, 'processed': True, 'content_size': 3517, '_rdd': <readability.api.Readability object at 0x7fece592d0d0>, 'id': u'ftpboxlq'}



#-- $ scp Gullinbursti@98.234.53.76:~/Downloads/Imaging-1.1.7.tar.gz `pwd` && tar -zxvf Imaging-1.1.7.tar.gz