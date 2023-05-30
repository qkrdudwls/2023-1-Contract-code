from oauth2client.service_account import ServiceAccountCredentials
import gspread
#import ipfshttpclient

scope=[
    "https://spreadsheets.google.com/feeds",
    "https://www.googleapis.com/auth/drive",
]

json_key_path="test.json"

credential=ServiceAccountCredentials.from_json_keyfile_name(json_key_path,scope)
gc=gspread.authorize(credential)

spreadsheet_url="https://docs.google.com/spreadsheets/d/1Es_Yn8n0c4MAMMSKLb0TWSkB-haR7kAn_LVOrxt7F0c/edit#gid=0"

doc=gc.open_by_url(spreadsheet_url)

sheet=doc.worksheet("Sheet1")
range_string='A2:A1000'

def counta(url,string):
    worksheet=doc.sheet1
    values=worksheet.range(string)
    count=0
    for cell in values:
        if cell.value !='':
            count+=1
    return count

result=counta(spreadsheet_url,range_string)
print("Count= ",result)