unit UfrmMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ToolWin, Inifiles, DB, ADODB, Grids, DBGrids, Menus,
  StdCtrls, ExtCtrls,PerlRegEx, DBCtrls, Buttons, ActnList;

type
  TfrmMain = class(TForm)
    ADOConnPEIS: TADOConnection;
    ADOConnEquip: TADOConnection;
    DataSource1: TDataSource;
    ADOQuery1: TADOQuery;
    ADOQuery2: TADOQuery;
    DataSource2: TDataSource;
    DataSource3: TDataSource;
    ADOQuery3: TADOQuery;
    StatusBar1: TStatusBar;
    GroupBox1: TGroupBox;
    DBGrid2: TDBGrid;
    PageControl2: TPageControl;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    DBGrid3: TDBGrid;
    Panel2: TPanel;
    Label2: TLabel;
    Memo2: TMemo;
    DBNavigator2: TDBNavigator;
    GroupBox2: TGroupBox;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    DBGrid1: TDBGrid;
    TabSheet2: TTabSheet;
    Memo1: TMemo;
    Panel1: TPanel;
    DBNavigator1: TDBNavigator;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    ActionList1: TActionList;
    Action1: TAction;
    Label1: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ADOQuery1AfterOpen(DataSet: TDataSet);
    procedure N1Click(Sender: TObject);
    procedure ADOQuery1AfterScroll(DataSet: TDataSet);
    procedure ADOQuery2AfterScroll(DataSet: TDataSet);
    procedure ADOQuery2AfterOpen(DataSet: TDataSet);
    procedure ADOQuery3AfterOpen(DataSet: TDataSet);
    procedure ADOQuery3AfterScroll(DataSet: TDataSet);
    procedure BitBtn2Click(Sender: TObject);
    procedure DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
  private
    { Private declarations }
    function MakeDBConn(const ADB:string;AADOConn:TADOConnection):boolean;
    procedure UpdateEquipAdoquery;
    procedure UpdateAdoquery3;
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

uses UCommFunction;

const
  sCryptSeed='lc';//加解密种子
  SYSNAME='PEIS'; 

var
  PeisConnStr:String;
  EquipConnStr:String;

{$R *.dfm}

function GetConnectString(const ADB:string):string;
//ADB:PEIS数据库、设备数据库
var
  Ini:tinifile;
  userid, password, datasource, initialcatalog: string;
  ifIntegrated:boolean;//是否集成登录模式

  pInStr,pDeStr:Pchar;
  i:integer;
begin
  result:='';
  
  Ini := tinifile.Create(ChangeFileExt(Application.ExeName,'.INI'));
  datasource := Ini.ReadString(ADB, '服务器', '');
  initialcatalog := Ini.ReadString(ADB, '数据库', '');
  ifIntegrated:=ini.ReadBool(ADB,'集成登录模式',false);
  userid := Ini.ReadString(ADB, '用户', '');
  password := Ini.ReadString(ADB, '口令', '107DFC967CDCFAAF');
  Ini.Free;
  //======解密password
  pInStr:=pchar(password);
  pDeStr:=DeCryptStr(pInStr,sCryptSeed);
  setlength(password,length(pDeStr));
  for i :=1  to length(pDeStr) do password[i]:=pDeStr[i-1];
  //==========

  result := result + 'user id=' + UserID + ';';
  result := result + 'password=' + Password + ';';
  result := result + 'data source=' + datasource + ';';
  result := result + 'Initial Catalog=' + initialcatalog + ';';
  result := result + 'provider=' + 'SQLOLEDB.1' + ';';
  //Persist Security Info,表示ADO在数据库连接成功后是否保存密码信息
  //ADO缺省为True,ADO.net缺省为False
  //程序中会传ADOConnection信息给TADOLYQuery,故设置为True
  result := result + 'Persist Security Info=True;';
  if ifIntegrated then
    result := result + 'Integrated Security=SSPI;';
end;

function TfrmMain.MakeDBConn(const ADB:string;AADOConn:TADOConnection): boolean;
//ADB:PEIS数据库、设备数据库
var
  newconnstr,ss: string;
  Label labReadIni;
begin
  result:=false;

  labReadIni:
  newconnstr := GetConnectString(ADB);
  
  try
    AADOConn.Connected := false;
    AADOConn.ConnectionString := newconnstr;
    AADOConn.Connected := true;
    result:=true;
    if ADB='PEIS数据库' then PeisConnStr:=newconnstr;
    if ADB='设备数据库' then EquipConnStr:=newconnstr;
  except
  end;
  if not result then
  begin
    ss:='服务器'+#2+'Edit'+#2+#2+'0'+#2+#2+#3+
        '数据库'+#2+'Edit'+#2+#2+'0'+#2+#2+#3+
        '集成登录模式'+#2+'CheckListBox'+#2+#2+'0'+#2+#2+#3+
        '用户'+#2+'Edit'+#2+#2+'0'+#2+#2+#3+
        '口令'+#2+'Edit'+#2+#2+'0'+#2+#2+'1';
    if ShowOptionForm('连接数据库',Pchar(ADB),Pchar(ss),Pchar(ChangeFileExt(Application.ExeName,'.ini'))) then
      goto labReadIni else application.Terminate;
  end;
end;

procedure TfrmMain.UpdateEquipAdoquery;
var
  ss1:string;
begin
  ss1:='SELECT TOP 1000 '+
      'P.PatientName as 姓名 '+
      ',P.PatientAge as 年龄 '+
      ',CASE UPPER(P.PatientSex) WHEN ''M'' THEN ''男'' when ''F'' THEN ''女'' else ''未知'' end as 性别 '+
      ',P.CreateDateTime as 创建时间 '+
      ',O.ClinicDepartment as 送检科室 '+
      ',O.ClinicDoctor as 送检医生 '+
      ',SR.StudyHint as 检查提示 '+
      ',SR.StudySee as 检查所见 '+
      ',P.PatientIdentity '+
      ',P.PatientID '+
      ',P.PatientBirthDate '+
      ',P.StudyCount '+
      ',P.LatestStudyDateTime '+
      ',P.Nation '+
      ',P.AlphabetCode '+

      ',O.OrderIdentity '+
      ',O.VisitIdentity '+
      ',O.ClinicDiaEdit '+
      ',O.TotalStudyFee '+
      ',O.DoctorRegist '+
      ',O.DateTimeRegist '+
      ',O.BookTime '+

      ',S.StudyIdentity '+
      ',S.StudyID '+
      ',S.StudyUID '+
      ',S.CheckSite '+
      ',S.StudyDoctor '+
      ',S.StudyDate '+
      ',S.BeginStudyTime '+
      ',S.EndStudyTime '+
      ',S.StudyState '+
      ',S.ReportState '+
      ',S.ImagePath '+
      ',S.DoctorPrint '+
      ',S.DateTimeUpdate '+
      ',S.DataTimePrint '+
      ',S.PositiveMark '+

      ',SR.StudyResultIdentity '+
      ',SR.LastUpdate '+
      ',SR.LastStudyDoctor '+

      ',PS.SendSuccNum '+// AS 发送成功次数
      //',PS.LastSendDes AS 最后发送情况 '+
      //',PS.LastSendTime AS 最后发送时间 '+

  'FROM T_Patient P '+
  'LEFT JOIN T_Order O ON O.PatientIdentity=P.PatientIdentity '+
  'LEFT JOIN T_Study S ON S.OrderIdentity=O.OrderIdentity '+
  'LEFT JOIN T_StudyResult SR ON SR.StudyIdentity=S.StudyIdentity '+
  'LEFT JOIN PEIS_Send PS ON PS.StudyResultIdentity=SR.StudyResultIdentity '+
  ' where S.StudyState=''已打印'' '+//只查询已完成报告单
  ' and O.ClinicDepartment=''体检'' '+//只查询体检报告单(申请科室=体检)
  ' and P.PatientName is not null and P.PatientName<>'''' '+//无姓名不发送
  'ORDER BY CreateDateTime DESC';
  ADOQuery1.Close;
  ADOQuery1.SQL.Clear;
  ADOQuery1.SQL.Add(ss1);
  ADOQuery1.Open;
end;

procedure TfrmMain.FormShow(Sender: TObject);
begin
  StatusBar1.Panels[2].Text:=SYSNAME;
  
  UpdateEquipAdoquery;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  MakeDBConn('设备数据库',ADOConnEquip);
  MakeDBConn('PEIS数据库',ADOConnPEIS);

  PageControl1.ActivePageIndex:=0;
  PageControl2.ActivePageIndex:=0;
end;

procedure TfrmMain.ADOQuery1AfterOpen(DataSet: TDataSet);
begin
  dbgrid1.Columns[0].Width:=42;
  dbgrid1.Columns[1].Width:=30;
  dbgrid1.Columns[2].Width:=30;
  dbgrid1.Columns[3].Width:=72;
  dbgrid1.Columns[4].Width:=60;
  dbgrid1.Columns[5].Width:=55;
  dbgrid1.Columns[6].Width:=300;
  dbgrid1.Columns[7].Width:=200;
end;

procedure TfrmMain.N1Click(Sender: TObject);
var
  adotemp3,adotemp4,adotemp5,adotemp555:tadoquery;
  jcts_itemid:string;//【检查提示】项目代码
  jcjl_itemid:string;//【检查结论】项目代码
  jcjy_itemid:string;//【检查建议】项目代码
  Eqip_Jcts:String;
  Eqip_Jcts2:String;
  Peis_Unid:String;
  Eqip_Jcts_List:TStrings;
  RegEx: TPerlRegEx;
  RegEx2: TPerlRegEx;
  RegEx3: TPerlRegEx;
  b3:boolean;
  i:integer;

  Peis_Jcjl:String;
  Peis_Jcjy:String;

  Peis_Jcts_Num:integer;
  Peis_Jcjl_Num:integer;
  Peis_Jcjy_Num:integer;

  StudyResultIdentity:String;
begin
  if ADOQuery1.RecordCount<=0 then
  begin
    MESSAGEDLG('无发送数据!',mtError,[MBOK],0);
    exit;
  end;
  Eqip_Jcts:=ADOQuery1.fieldbyname('检查提示').AsString;
  if trim(Eqip_Jcts)='' then
  begin
    MESSAGEDLG('检查提示为空!',mtError,[MBOK],0);
    exit;
  end;
  if ADOQuery2.RecordCount<=0 then
  begin
    MESSAGEDLG('PEIS无该受检者!',mtError,[MBOK],0);
    exit;
  end;
  if ADOQuery2.RecordCount>1 then
  begin
    MESSAGEDLG('该受检者在PEIS有多条记录!',mtError,[MBOK],0);
    exit;
  end;
  if ADOQuery2.FieldByName('审核者').AsString<>'' then
  begin
    MESSAGEDLG('该受检者在PEIS已审核!',mtError,[MBOK],0);
    exit;
  end;

  adotemp3:=tadoquery.Create(nil);
  adotemp3.Connection:=ADOConnPEIS;
  adotemp3.Close;
  adotemp3.SQL.Clear;
  adotemp3.SQL.Text:='select itemid from clinicchkitem cci where cci.Reserve5=3 ';
  adotemp3.Open;
  if adotemp3.RecordCount<=0 then
  begin
    MESSAGEDLG('不存在彩超【检查提示】项目(保留字段5=3).请管理员检查项目设置!',mtError,[MBOK],0);
    adotemp3.Free;
    exit;
  end;
  if adotemp3.RecordCount>1 then
  begin
    MESSAGEDLG('存在多条彩超【检查提示】项目(保留字段5=3).请管理员检查项目设置!',mtError,[MBOK],0);
    adotemp3.Free;
    exit;
  end;
  jcts_itemid:=adotemp3.fieldbyname('itemid').AsString;
  adotemp3.Free;

  adotemp4:=tadoquery.Create(nil);
  adotemp4.Connection:=ADOConnPEIS;
  adotemp4.Close;
  adotemp4.SQL.Clear;
  adotemp4.SQL.Text:='select itemid from clinicchkitem cci where cci.Reserve5=1 ';
  adotemp4.Open;
  if adotemp4.RecordCount<=0 then
  begin
    MESSAGEDLG('不存在【检查结论】项目(保留字段5=1).请管理员检查项目设置!',mtError,[MBOK],0);
    adotemp4.Free;
    exit;
  end;
  if adotemp4.RecordCount>1 then
  begin
    MESSAGEDLG('存在多条【检查结论】项目(保留字段5=1).请管理员检查项目设置!',mtError,[MBOK],0);
    adotemp4.Free;
    exit;
  end;
  jcjl_itemid:=adotemp4.fieldbyname('itemid').AsString;
  adotemp4.Free;

  adotemp5:=tadoquery.Create(nil);
  adotemp5.Connection:=ADOConnPEIS;
  adotemp5.Close;
  adotemp5.SQL.Clear;
  adotemp5.SQL.Text:='select itemid from clinicchkitem cci where cci.Reserve5=2 ';
  adotemp5.Open;
  if adotemp5.RecordCount<=0 then
  begin
    MESSAGEDLG('不存在【检查建议】项目(保留字段5=2).请管理员检查项目设置!',mtError,[MBOK],0);
    adotemp5.Free;
    exit;
  end;
  if adotemp5.RecordCount>1 then
  begin
    MESSAGEDLG('存在多条【检查建议】项目(保留字段5=2).请管理员检查项目设置!',mtError,[MBOK],0);
    adotemp5.Free;
    exit;
  end;
  jcjy_itemid:=adotemp5.fieldbyname('itemid').AsString;
  adotemp5.Free;

  Peis_Unid:=ADOQuery2.fieldbyname('Unid').AsString;

  Peis_Jcts_Num:=strtoint(ScalarSQLCmd(PeisConnStr,'select count(*) from chk_valu cv where cv.pkunid='+Peis_Unid+' and cv.itemid='''+jcts_itemid+''' '));
  if Peis_Jcts_Num<=0 then
  begin
    ExecSQLCmd(PeisConnStr,'insert into chk_valu (pkunid,itemid,itemvalue) values ('+Peis_Unid+','''+jcts_itemid+''','''+Eqip_Jcts+''')');
  end else
  begin
    //if (MessageDlg('PEIS存在检查数据,将覆盖原有检查数据,确定吗？', mtConfirmation, [mbYes, mbNo], 0) <> mrYes) then exit;
    ExecSQLCmd(PeisConnStr,'update chk_valu set itemvalue='''+Eqip_Jcts+''' where pkunid='+Peis_Unid+' and itemid='''+jcts_itemid+''' ');
  end;

  adotemp555:=tadoquery.Create(nil);
  adotemp555.Connection:=ADOConnPEIS;
  adotemp555.Close;
  adotemp555.SQL.Clear;
  adotemp555.SQL.Text:='select name,Reserve2 from CommCode where TypeName=''异常建议'' ';
  adotemp555.Open;

  RegEx := TPerlRegEx.Create;
  RegEx.Subject := Eqip_Jcts;
  RegEx.RegEx   := '。|；';//用|分隔多个分隔符.正则表达式|表示"或"
  Eqip_Jcts_List:=TStringList.Create;
  RegEx.Split(Eqip_Jcts_List,MaxInt);//MaxInt,表示能分多少就分多少
  FreeAndNil(RegEx);
  for i :=0  to Eqip_Jcts_List.Count-1 do
  begin
    if pos('未见明显异常',Eqip_Jcts_List[i])>0 then continue;
    
    //生成检查结论begin
    //删除检查提示中的序号(如1、23、)
    RegEx2 := TPerlRegEx.Create;
    RegEx2.Subject := Eqip_Jcts_List[i];
    RegEx2.RegEx   := '\d{1,2}、';
    RegEx2.Replacement:='';
    RegEx2.ReplaceAll;
    Eqip_Jcts2:=RegEx2.Subject;
    FreeAndNil(RegEx2);
    if trim(Eqip_Jcts2)<>'' then Peis_Jcjl:=Peis_Jcjl+Eqip_Jcts2+'。'+#13;//检查结论
    //生成检查结论end

    //生成检查建议begin
    adotemp555.First;
    while not adotemp555.Eof do
    begin
      //匹配异常关键字
      RegEx3 := TPerlRegEx.Create;
      RegEx3.Subject := Eqip_Jcts_List[i];
      RegEx3.RegEx   := adotemp555.fieldbyname('name').AsString;
      b3:=RegEx3.Match;
      FreeAndNil(RegEx3);
      if b3 then Peis_Jcjy:=Peis_Jcjy+adotemp555.fieldbyname('Reserve2').AsString+#13;
      adotemp555.Next;
    end;
    //生成检查建议end
  end;
  Eqip_Jcts_List.Free;
  adotemp555.Free;

  Peis_Jcjl_Num:=strtoint(ScalarSQLCmd(PeisConnStr,'select count(*) from chk_valu cv where cv.pkunid='+Peis_Unid+' and cv.itemid='''+jcjl_itemid+''' '));
  if Peis_Jcjl_Num<=0 then
  begin
    ExecSQLCmd(PeisConnStr,'insert into chk_valu (pkunid,itemid,itemvalue) values ('+Peis_Unid+','''+jcjl_itemid+''','''+Peis_Jcjl+''')');
  end else
  begin
    ExecSQLCmd(PeisConnStr,'update chk_valu set itemvalue=itemvalue+'''+Peis_Jcjl+''' where pkunid='+Peis_Unid+' and itemid='''+jcjl_itemid+''' ');
  end;

  Peis_Jcjy_Num:=strtoint(ScalarSQLCmd(PeisConnStr,'select count(*) from chk_valu cv where cv.pkunid='+Peis_Unid+' and cv.itemid='''+jcjy_itemid+''' '));
  if Peis_Jcjy_Num<=0 then
  begin
    ExecSQLCmd(PeisConnStr,'insert into chk_valu (pkunid,itemid,itemvalue) values ('+Peis_Unid+','''+jcjy_itemid+''','''+Peis_Jcjy+''')');
  end else
  begin
    ExecSQLCmd(PeisConnStr,'update chk_valu set itemvalue=itemvalue+'''+Peis_Jcjy+''' where pkunid='+Peis_Unid+' and itemid='''+jcjy_itemid+''' ');
  end;

  ADOQuery3.Requery;

  StudyResultIdentity:=ADOQuery1.fieldbyname('StudyResultIdentity').AsString;
  
  if strtoint(ScalarSQLCmd(EquipConnStr,'select count(*) from PEIS_Send ps where ps.StudyResultIdentity='+StudyResultIdentity))<=0 then
    ExecSQLCmd(EquipConnStr,'insert into PEIS_Send (StudyResultIdentity,SendSuccNum) values ('+StudyResultIdentity+',1)')
  else ExecSQLCmd(EquipConnStr,'update PEIS_Send set SendSuccNum=SendSuccNum+1 where StudyResultIdentity='+StudyResultIdentity);

  BitBtn2Click(BitBtn2);//用于刷新已发送的颜色

  MESSAGEDLG('发送完成!',mtInformation,[MBOK],0);
end;

procedure TfrmMain.ADOQuery1AfterScroll(DataSet: TDataSet);
var
  ss1:string;
begin
    	ss1:='select cc.patientname as 姓名,cc.age as 年龄,cc.sex as 性别,cc.check_date as 检查日期,cc.report_doctor as 审核者,cc.combin_id as 工作组,cc.Caseno as 病历号,cc.deptname as 送检科室,cc.check_doctor as 送检医生,cc.unid '+
    	' from chk_con cc,CommCode cco '+
    	' where cco.TypeName=''检验组别'' and cco.SysName='''+SYSNAME+
      ''' and cc.combin_id=cco.name '+
      ' AND cc.patientname='''+ADOQuery1.FieldByName('姓名').AsString+
    	''' and isnull(cc.sex,'''')='''+ADOQuery1.FieldByName('性别').AsString+
    	''' and dbo.uf_GetAgeReal(cc.age)=dbo.uf_GetAgeReal('''+ADOQuery1.FieldByName('年龄').AsString+''') ';

    ADOQuery2.Close;
    ADOQuery2.SQL.Clear;
    ADOQuery2.SQL.Text:=SS1;
    ADOQuery2.Open;

  //更新结果详情
  Memo1.Lines.Text:=DataSet.fieldbyname('姓名').AsString+
              ' '+
              DataSet.fieldbyname('年龄').AsString+
              ' '+
              DataSet.fieldbyname('性别').AsString+
              ' '+
              FormatDateTime('YYYY-MM-DD',DataSet.fieldbyname('创建时间').AsDateTime)+
              #13#13+
              DataSet.fieldbyname('检查提示').AsString;
end;

procedure TfrmMain.ADOQuery2AfterScroll(DataSet: TDataSet);
begin
  UpdateAdoquery3;
end;

procedure TfrmMain.ADOQuery2AfterOpen(DataSet: TDataSet);
begin
  dbgrid2.Columns[0].Width:=42;
  dbgrid2.Columns[1].Width:=30;
  dbgrid2.Columns[2].Width:=30;
  dbgrid2.Columns[3].Width:=72;
  dbgrid2.Columns[4].Width:=42;

  if DataSet.RecordCount<1 then UpdateAdoquery3;
end;

procedure TfrmMain.ADOQuery3AfterOpen(DataSet: TDataSet);
begin
  dbgrid3.Columns[1].Width:=80;
  dbgrid3.Columns[2].Width:=50;
  dbgrid3.Columns[3].Width:=300;
  dbgrid3.Columns[4].Width:=50;
  dbgrid3.Columns[5].Width:=50;
  dbgrid3.Columns[6].Width:=50;

  //更新结果详情
  if DataSet.RecordCount<=0 then
  begin
    Memo2.Lines.Clear;
    Label2.Caption:='';
  end;
end;

procedure TfrmMain.UpdateAdoquery3;
var
  ss1:string;
  ss2:string;
begin
  if (ADOQuery2.Active)and(ADOQuery2.RecordCount>=1) then ss2:=ADOQuery2.fieldbyname('Unid').AsString else ss2:='-1';
  
    	ss1:=' select '+
      '(case cv.issure when 1 then ''√'' else '''' end) as 勾,'+
      ' cv.Name as 名称,cv.english_name as 英文名,cv.itemvalue as 结果,cv.Min_value as 最小值,cv.Max_value as 最大值,cv.Unit as 单位,cv.pkcombin_id,cv.combin_Name,cv.pkunid,cv.valueid '+
    	' from chk_valu cv '+
    	' where '+
      ' cv.pkunid='+ss2+
      ' and cv.Reserve5 in (3,1,2) '+
      ' order by cv.printorder ';

    ADOQuery3.Close;
    ADOQuery3.SQL.Clear;
    ADOQuery3.SQL.Text:=SS1;
    ADOQuery3.Open;
end;

procedure TfrmMain.ADOQuery3AfterScroll(DataSet: TDataSet);
begin
  //更新结果详情
  Memo2.Lines.Text:=DataSet.fieldbyname('结果').AsString;
  Label2.Caption:=DataSet.fieldbyname('名称').AsString;
end;

procedure TfrmMain.BitBtn2Click(Sender: TObject);
var
  PatientIdentity:String;
begin
  PatientIdentity:=ADOQuery1.fieldbyname('PatientIdentity').AsString;
  ADOQuery1.Requery;
  ADOQuery1.Locate('PatientIdentity',PatientIdentity,[loCaseInsensitive]) ;
end;

procedure TfrmMain.DBGrid1DrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn;
  State: TGridDrawState);
var
  strSendSuccNum:String;
  SendSuccNum:integer;
begin
  //发送过的姓名列变化颜色
  if datacol=0 then
  begin
    strSendSuccNum:=tdbgrid(sender).DataSource.DataSet.fieldbyname('SendSuccNum').AsString;
    SendSuccNum:=strtointdef(strSendSuccNum,0);
    IF SendSuccNum>0 then
    begin
      tdbgrid(sender).Canvas.Font.Color:=clred;
      tdbgrid(sender).DefaultDrawColumnCell(rect,datacol,column,state);
    end;
  end;
end;

end.
