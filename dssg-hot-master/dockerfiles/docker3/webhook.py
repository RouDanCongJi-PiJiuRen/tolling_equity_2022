from flask import Flask, request
import re
import requests

app = Flask(__name__)

@app.route('/',methods=['POST'])
def foo():
    data = request.form.to_dict()
    bodystr = list(data.values())[0]
    #print(type(bodystr))
    #print(bodystr)

    def findurl(string_with_url):
        url = re.findall('http[s]?://(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*\(\), ]|(?:%[0-9a-fA-F][0-9a-fA-F]))+.zip', string_with_url);
        return url
    
    dlurl = findurl(bodystr)[0]
    fsavename_start = dlurl.find('trip/')+5
    fsavename_end = dlurl.find('M-F')+3
    fsavename_short = dlurl[fsavename_start:fsavename_end] 
    fsavename = '/opt/dssg-hot/data/shirleydata/traveltimes/'+fsavename_short+'.zip'
    print("#################dlurl: ", dlurl)
    print("#################fsavename: ", fsavename)

    r = requests.get(dlurl) # create HTTP response object 
    # send a HTTP request to the server and save 
    # the HTTP response in a response object called r 
    with open(fsavename,'wb') as f: 
        # write the contents of the response (r.content) 
        # to a new file in binary mode. 
        f.write(r.content) 

    return "OK"

if __name__ == '__main__':
   app.run(host='0.0.0.0',port=80)
