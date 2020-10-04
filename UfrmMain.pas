unit UfrmMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ToolWin, Inifiles, DB, ADODB, Grids, DBGrids, Menus,
  StdCtrls, ExtCtrls,PerlRegEx, DBCtrls, Buttons, ActnList, Math, StrUtils;

type TArCheckBoxValue = array of array [0..1] of integer;
  
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
    ActionList1: TActionList;
    Action1: TAction;
    Label1: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    Label6: TLabel;
    Label7: TLabel;
    DateTimePicker1: TDateTimePicker;
    DateTimePicker2: TDateTimePicker;
    LabeledEdit1: TLabeledEdit;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ADOQuery1AfterOpen(DataSet: TDataSet);
    procedure ADOQuery1AfterScroll(DataSet: TDataSet);
    procedure ADOQuery2AfterScroll(DataSet: TDataSet);
    procedure ADOQuery2AfterOpen(DataSet: TDataSet);
    procedure ADOQuery3AfterOpen(DataSet: TDataSet);
    procedure ADOQuery3AfterScroll(DataSet: TDataSet);
    procedure DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure BitBtn1Click(Sender: TObject);
    procedure DBGrid1CellClick(Column: TColumn);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure DateTimePicker1Change(Sender: TObject);
    procedure DateTimePicker2Change(Sender: TObject);
    procedure LabeledEdit1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    function MakeDBConn(const ADB:string;AADOConn:TADOConnection):boolean;
    procedure UpdateEquipAdoquery;
    function BuildPeisSQL(const AName,ASex,AAge:string):String;
    procedure UpdateAdoquery3;
    function singleSend2Peis(const AEquipUnid,AEquipName,AEquipSex,AEquipAge,AEquipJcts:String):boolean;
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
  ArCheckBoxValue:TArCheckBoxValue;

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
  ss1:='SELECT TOP 3000 '+//2个月的体检量
      'P.PatientName as 姓名 '+
      ',P.PatientAge as 年龄 '+
      ',CASE UPPER(P.PatientSex) WHEN ''M'' THEN ''男'' when ''F'' THEN ''女'' else ''未知'' end as 性别 '+
      ',0 as 选择 '+
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
  ' and isnull(SR.StudyHint,'''')<>'''' '+//无检查提示不发送//意味着StudyResultIdentity有值
  ' AND P.CreateDateTime between :begin_study_dttm and :end_study_dttm '+
  ifThen(trim(LabeledEdit1.Text)<>'',' and O.ClinicDoctor like '''+trim(LabeledEdit1.Text)+'%'' ')+
  ' ORDER BY CreateDateTime DESC';
  ADOQuery1.Close;
  ADOQuery1.SQL.Clear;
  ADOQuery1.SQL.Add(ss1);
  ADOQuery1.Parameters.ParamByName('begin_study_dttm').Value:=DateTimePicker1.DateTime;
  ADOQuery1.Parameters.ParamByName('end_study_dttm').Value:=DateTimePicker2.DateTime;
  ADOQuery1.Open;
end;

procedure TfrmMain.FormShow(Sender: TObject);
begin
  StatusBar1.Panels[2].Text:=SYSNAME;
  
  DateTimePicker1.Date := now-30;
  DateTimePicker1.Time := StrToTime('00:00:01');
  DateTimePicker2.Date := now;
  DateTimePicker2.Time := StrToTime('23:59:59');

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
var
  adotemp22:tadoquery;
  i:integer;
begin
  dbgrid1.Columns[0].Width:=42;
  dbgrid1.Columns[1].Width:=30;
  dbgrid1.Columns[2].Width:=30;
  dbgrid1.Columns[3].Width:=30;//选择
  dbgrid1.Columns[4].Width:=72;
  dbgrid1.Columns[5].Width:=60;
  dbgrid1.Columns[6].Width:=55;
  dbgrid1.Columns[7].Width:=300;
  dbgrid1.Columns[8].Width:=200;

  adotemp22:=tadoquery.Create(nil);
  adotemp22.clone(DataSet as TCustomADODataSet);
  ArCheckBoxValue:=nil;
  setlength(ArCheckBoxValue,adotemp22.RecordCount);
  i:=0;
  while not adotemp22.Eof do
  begin
    //该二维数组中一定要有个字段标识唯一性的
    ArCheckBoxValue[I,0]:=0;
    ArCheckBoxValue[I,1]:=adotemp22.FieldByName('StudyResultIdentity').AsInteger;

    adotemp22.Next;
    inc(i);
  end;
  adotemp22.Free;
end;

procedure TfrmMain.ADOQuery1AfterScroll(DataSet: TDataSet);
begin
    ADOQuery2.Close;
    ADOQuery2.SQL.Clear;
    ADOQuery2.SQL.Text:=BuildPeisSQL(DataSet.FieldByName('姓名').AsString,DataSet.FieldByName('性别').AsString,DataSet.FieldByName('年龄').AsString);
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

procedure TfrmMain.DBGrid1DrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn;
  State: TGridDrawState);
const
  CtrlState: array[Boolean] of Integer = (DFCS_BUTTONCHECK, DFCS_BUTTONCHECK or DFCS_CHECKED);
var
  strSendSuccNum:String;
  SendSuccNum:integer;
  
  checkBox_check:boolean;
  iUNID,i:INTEGER;
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

  if Column.Field.FieldName='选择' then
  begin
    (sender as TDBGrid).Canvas.FillRect(Rect);
    checkBox_check:=false;
    iUNID:=(Sender AS TDBGRID).DataSource.DataSet.FieldByName('StudyResultIdentity').AsInteger;
    for i :=0  to (Sender AS TDBGRID).DataSource.DataSet.RecordCount-1 do
    begin
      if ArCheckBoxValue[i,1]=iUNID then
      begin
        checkBox_check:=ArCheckBoxValue[i,0]=1;
        break;
      end;
    end;//}
    DrawFrameControl((sender as TDBGrid).Canvas.Handle,Rect, DFC_BUTTON, CtrlState[checkBox_check]);
  end else (sender as TDBGrid).DefaultDrawColumnCell(Rect,DataCol,Column,State);
end;

procedure TfrmMain.BitBtn1Click(Sender: TObject);
var
  i:integer;
  Save_Cursor:TCursor;
  adotemp11:tadoquery;
  ifSelect:boolean;
  StudyResultIdentity:String;
begin
  if (not ADOQuery1.Active)or(ADOQuery1.RecordCount<=0) then
  begin
    MESSAGEDLG('无发送数据!',mtError,[MBOK],0);
    exit;
  end;

  (Sender as TBitBtn).Enabled:=false;

  Save_Cursor := Screen.Cursor;
  Screen.Cursor := crHourGlass;

  adotemp11:=tadoquery.Create(nil);
  adotemp11.clone(ADOQuery1);
  while not adotemp11.Eof do
  begin
    ifSelect:=false;
    for i :=low(ArCheckBoxValue)  to high(ArCheckBoxValue) do//循环ArCheckBoxValue
    begin
      if (ArCheckBoxValue[i,1]=adotemp11.fieldbyname('StudyResultIdentity').AsInteger)and(ArCheckBoxValue[i,0]=1) then
      begin
        ifSelect:=true;
        break;
      end;
    end;
    if not ifSelect then begin adotemp11.Next;continue;end;//如果未选择，则跳过

    singleSend2Peis(adotemp11.FieldByName('StudyResultIdentity').AsString,adotemp11.FieldByName('姓名').AsString,adotemp11.FieldByName('性别').AsString,adotemp11.FieldByName('年龄').AsString,adotemp11.FieldByName('检查提示').AsString);

    adotemp11.Next;
  end;
  adotemp11.Free;

  //用于刷新已发送的颜色//该语句一定会触发UpdateAdoquery3方法。故无需再次ADOQuery3.Requery;
  StudyResultIdentity:=ADOQuery1.fieldbyname('StudyResultIdentity').AsString;
  UpdateEquipAdoquery;
  ADOQuery1.Locate('StudyResultIdentity',StudyResultIdentity,[loCaseInsensitive]) ;

  Screen.Cursor := Save_Cursor;  { Always restore to normal }
  
  (Sender as TBitBtn).Enabled:=true;

  MESSAGEDLG('发送操作已完成!',mtInformation,[MBOK],0);
end;

function TfrmMain.BuildPeisSQL(const AName, ASex, AAge: string): String;
begin
  result:='select cc.patientname as 姓名,cc.age as 年龄,cc.sex as 性别,cc.check_date as 检查日期,cc.report_doctor as 审核者,cc.combin_id as 工作组,cc.Caseno as 病历号,cc.deptname as 送检科室,cc.check_doctor as 送检医生,cc.unid '+
    	' from chk_con cc,CommCode cco '+
    	' where cco.TypeName=''检验组别'' and cco.SysName='''+SYSNAME+
      ''' and cc.combin_id=cco.name '+
      ' AND cc.patientname='''+AName+
    	''' and isnull(cc.sex,'''')='''+ASex+
    	''' and dbo.uf_GetAgeReal(cc.age)=dbo.uf_GetAgeReal('''+AAge+''') ';
end;

function TfrmMain.singleSend2Peis(const AEquipUnid,AEquipName,AEquipSex,AEquipAge,AEquipJcts:String): boolean;
var
  adotemp3,adotemp4,adotemp5,adotemp555:tadoquery;
  jcts_itemid:string;//【检查提示】项目代码
  jcjl_itemid:string;//【检查结论】项目代码
  jcjy_itemid:string;//【检查建议】项目代码
  jcjl_combinid:string;//【检查结论】组合项目代码
  jcjy_combinid:string;//【检查建议】组合项目代码
  Eqip_Jcts2:String;
  Eqip_Jcts4:String;
  Peis_Unid:String;
  Eqip_Jcts_List:TStrings;
  RegEx: TPerlRegEx;
  RegEx2: TPerlRegEx;
  RegEx3: TPerlRegEx;
  RegEx4: TPerlRegEx;
  b3:boolean;
  i:integer;

  Peis_Jcjl:String;
  Peis_Jcjy:String;

  Peis_Jcts_Num:integer;
  Peis_Jcjl_Num:integer;
  Peis_Jcjy_Num:integer;

  adotemp44:tadoquery;
begin
  result:=false;

  adotemp44:=tadoquery.Create(nil);
  adotemp44.Connection:=ADOConnPEIS;
  adotemp44.Close;
  adotemp44.SQL.Clear;
  adotemp44.SQL.Text:=BuildPeisSQL(AEquipName,AEquipSex,AEquipAge);
  adotemp44.Open;
  if adotemp44.RecordCount<=0 then
  begin
    MESSAGEDLG(AEquipName+':PEIS无该受检者!',mtError,[MBOK],0);
    adotemp44.Free;
    exit;
  end;
  if adotemp44.RecordCount>1 then
  begin
    MESSAGEDLG(AEquipName+':该受检者在PEIS有多条记录!',mtError,[MBOK],0);
    adotemp44.Free;
    exit;
  end;
  if adotemp44.FieldByName('审核者').AsString<>'' then
  begin
    MESSAGEDLG(AEquipName+':该受检者在PEIS已审核!',mtError,[MBOK],0);
    adotemp44.Free;
    exit;
  end;
  Peis_Unid:=adotemp44.fieldbyname('Unid').AsString;
  adotemp44.Free;
  
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
  adotemp4.SQL.Text:='select cci.itemid,cbi.id from clinicchkitem cci,CombSChkItem csi,combinitem cbi where cci.Reserve5=1 and cci.unid=csi.itemunid and csi.combunid=cbi.unid and cci.SysName=''PEIS'' and cbi.SysName=''PEIS'' ';
  adotemp4.Open;
  if adotemp4.RecordCount<=0 then
  begin
    MESSAGEDLG('不存在【检查结论】项目(保留字段5=1)或不存在组合项目.请管理员检查项目设置!',mtError,[MBOK],0);
    adotemp4.Free;
    exit;
  end;
  if adotemp4.RecordCount>1 then
  begin
    MESSAGEDLG('存在多条【检查结论】项目(保留字段5=1)或属于多个组合项目.请管理员检查项目设置!',mtError,[MBOK],0);
    adotemp4.Free;
    exit;
  end;
  jcjl_itemid:=adotemp4.fieldbyname('itemid').AsString;
  jcjl_combinid:=adotemp4.fieldbyname('id').AsString;
  adotemp4.Free;

  adotemp5:=tadoquery.Create(nil);
  adotemp5.Connection:=ADOConnPEIS;
  adotemp5.Close;
  adotemp5.SQL.Clear;
  adotemp5.SQL.Text:='select cci.itemid,cbi.id from clinicchkitem cci,CombSChkItem csi,combinitem cbi where cci.Reserve5=2 and cci.unid=csi.itemunid and csi.combunid=cbi.unid and cci.SysName=''PEIS'' and cbi.SysName=''PEIS'' ';
  adotemp5.Open;
  if adotemp5.RecordCount<=0 then
  begin
    MESSAGEDLG('不存在【检查建议】项目(保留字段5=2)或不存在组合项目.请管理员检查项目设置!',mtError,[MBOK],0);
    adotemp5.Free;
    exit;
  end;
  if adotemp5.RecordCount>1 then
  begin
    MESSAGEDLG('存在多条【检查建议】项目(保留字段5=2)或属于多个组合项目.请管理员检查项目设置!',mtError,[MBOK],0);
    adotemp5.Free;
    exit;
  end;
  jcjy_itemid:=adotemp5.fieldbyname('itemid').AsString;
  jcjy_combinid:=adotemp5.fieldbyname('id').AsString;
  adotemp5.Free;

  Peis_Jcts_Num:=strtoint(ScalarSQLCmd(PeisConnStr,'select count(*) from chk_valu cv where cv.pkunid='+Peis_Unid+' and cv.itemid='''+jcts_itemid+''' '));
  if Peis_Jcts_Num<=0 then
  begin
    ExecSQLCmd(PeisConnStr,'insert into chk_valu (pkunid,itemid,itemvalue) values ('+Peis_Unid+','''+jcts_itemid+''','''+AEquipJcts+''')');
  end else
  begin
    //if (MessageDlg('PEIS存在检查数据,将覆盖原有检查数据,确定吗？', mtConfirmation, [mbYes, mbNo], 0) <> mrYes) then exit;
    ExecSQLCmd(PeisConnStr,'update chk_valu set itemvalue='''+AEquipJcts+''' where pkunid='+Peis_Unid+' and itemid='''+jcts_itemid+''' ');
  end;

  RegEx := TPerlRegEx.Create;
  RegEx.Subject := AEquipJcts;
  RegEx.RegEx   := '。|；';//用|分隔多个分隔符.正则表达式|表示"或"
  Eqip_Jcts_List:=TStringList.Create;
  try
    RegEx.Split(Eqip_Jcts_List,MaxInt);//MaxInt,表示能分多少就分多少
  except
    on E:Exception do
    begin
      WriteLog(pchar(AEquipName+':RegEx.Split失败:'+E.Message));
      MESSAGEDLG(AEquipName+':RegEx.Split失败:'+E.Message,mtError,[mbOK],0);
      FreeAndNil(RegEx);
      Eqip_Jcts_List.Free;
      exit;
    end;
  end;
  FreeAndNil(RegEx);
  for i :=0  to Eqip_Jcts_List.Count-1 do
  begin
    if pos('未见明显异常',Eqip_Jcts_List[i])>0 then continue;
    
    //生成检查结论begin
    //删除检查提示中的序号(如1、23、)
    RegEx2 := TPerlRegEx.Create;
    RegEx2.Subject := trim(Eqip_Jcts_List[i]);
    RegEx2.RegEx   := '^\d{1,2}、';
    RegEx2.Replacement:='';
    try
      RegEx2.ReplaceAll;
    except
      on E:Exception do
      begin
        WriteLog(pchar(AEquipName+':Subject:'+trim(Eqip_Jcts_List[i])+'.删除检查提示序号RegEx.ReplaceAll失败:'+E.Message));
        MESSAGEDLG(AEquipName+':Subject:'+trim(Eqip_Jcts_List[i])+'.删除检查提示序号RegEx.ReplaceAll失败:'+E.Message,mtError,[mbOK],0);
        FreeAndNil(RegEx2);
        Eqip_Jcts_List.Free;
        exit;
      end;
    end;
    Eqip_Jcts2:=RegEx2.Subject;
    FreeAndNil(RegEx2);

    //删除检查提示中的建议
    RegEx4 := TPerlRegEx.Create;
    RegEx4.Subject := Eqip_Jcts2;
    RegEx4.RegEx   := '，建议[\s\S]*';
    RegEx4.Replacement:='';
    try
      RegEx4.ReplaceAll;
    except
      on E:Exception do
      begin
        WriteLog(pchar(AEquipName+':Subject:'+Eqip_Jcts2+'.删除检查提示建议RegEx.ReplaceAll失败:'+E.Message));
        MESSAGEDLG(AEquipName+':Subject:'+Eqip_Jcts2+'.删除检查提示建议RegEx.ReplaceAll失败:'+E.Message,mtError,[mbOK],0);
        FreeAndNil(RegEx4);
        Eqip_Jcts_List.Free;
        exit;
      end;
    end;
    Eqip_Jcts4:=RegEx4.Subject;
    FreeAndNil(RegEx4);
    
    if trim(Eqip_Jcts4)<>'' then Peis_Jcjl:=Peis_Jcjl+trim(Eqip_Jcts4)+'。'+#13;//检查结论
    //生成检查结论end

    //生成检查建议begin
    adotemp555:=tadoquery.Create(nil);
    adotemp555.Connection:=ADOConnPEIS;
    adotemp555.Close;
    adotemp555.SQL.Clear;
    adotemp555.SQL.Text:='select name,Reserve2 from CommCode where TypeName=''异常建议'' ';
    adotemp555.Open;
    while not adotemp555.Eof do
    begin
      //匹配异常关键字
      RegEx3 := TPerlRegEx.Create;
      RegEx3.Subject := Eqip_Jcts_List[i];
      RegEx3.RegEx   := adotemp555.fieldbyname('name').AsString;
      try
        b3:=RegEx3.Match;
      except
        on E:Exception do
        begin
          WriteLog(pchar(AEquipName+':Subject:'+Eqip_Jcts_List[i]+'.RegEx.Match失败:'+E.Message+'.正则表达式:'+adotemp555.fieldbyname('name').AsString));
          MESSAGEDLG(AEquipName+':Subject:'+Eqip_Jcts_List[i]+'.RegEx.Match失败:'+E.Message+'.正则表达式:'+adotemp555.fieldbyname('name').AsString,mtError,[mbOK],0);
          FreeAndNil(RegEx3);
          Eqip_Jcts_List.Free;
          adotemp555.Free;
          exit;
        end;
      end;
      FreeAndNil(RegEx3);
      if b3 then Peis_Jcjy:=Peis_Jcjy+adotemp555.fieldbyname('Reserve2').AsString+#13;
      adotemp555.Next;
    end;
    adotemp555.Free;
    //生成检查建议end
  end;
  Eqip_Jcts_List.Free;

  Peis_Jcjl_Num:=strtoint(ScalarSQLCmd(PeisConnStr,'select count(*) from chk_valu cv where cv.pkunid='+Peis_Unid+' and cv.itemid='''+jcjl_itemid+''' '));
  if Peis_Jcjl_Num<=0 then
  begin
    ExecSQLCmd(PeisConnStr,'insert into chk_valu (pkunid,pkcombin_id,itemid,itemvalue) values ('+Peis_Unid+','''+jcjl_combinid+''','''+jcjl_itemid+''','''+Peis_Jcjl+''')');
  end else
  begin
    ExecSQLCmd(PeisConnStr,'update chk_valu set itemvalue=itemvalue+'''+Peis_Jcjl+''' where pkunid='+Peis_Unid+' and itemid='''+jcjl_itemid+''' ');
  end;

  Peis_Jcjy_Num:=strtoint(ScalarSQLCmd(PeisConnStr,'select count(*) from chk_valu cv where cv.pkunid='+Peis_Unid+' and cv.itemid='''+jcjy_itemid+''' '));
  if Peis_Jcjy_Num<=0 then
  begin
    ExecSQLCmd(PeisConnStr,'insert into chk_valu (pkunid,pkcombin_id,itemid,itemvalue) values ('+Peis_Unid+','''+jcjy_combinid+''','''+jcjy_itemid+''','''+Peis_Jcjy+''')');
  end else
  begin
    ExecSQLCmd(PeisConnStr,'update chk_valu set itemvalue=itemvalue+'''+Peis_Jcjy+''' where pkunid='+Peis_Unid+' and itemid='''+jcjy_itemid+''' ');
  end;

  if strtoint(ScalarSQLCmd(EquipConnStr,'select count(*) from PEIS_Send ps where ps.StudyResultIdentity='+AEquipUnid))<=0 then
    ExecSQLCmd(EquipConnStr,'insert into PEIS_Send (StudyResultIdentity,SendSuccNum) values ('+AEquipUnid+',1)')
  else ExecSQLCmd(EquipConnStr,'update PEIS_Send set SendSuccNum=SendSuccNum+1 where StudyResultIdentity='+AEquipUnid);

  result:=true;
end;

procedure TfrmMain.DBGrid1CellClick(Column: TColumn);
var
  iUNID,i:INTEGER;
begin
  if not Column.Grid.DataSource.DataSet.Active then exit;  
  if Column.Field.FieldName <>'选择' then exit;

  iUNID:=Column.Grid.DataSource.DataSet.FieldByName('StudyResultIdentity').AsInteger;
  for i :=low(ArCheckBoxValue)  to high(ArCheckBoxValue) do//循环ArCheckBoxValue
  begin
    if ArCheckBoxValue[i,1]=iUNID then
    begin
      ArCheckBoxValue[i,0]:=ifThen(ArCheckBoxValue[i,0]=1,0,1);
      Column.Grid.Refresh;//调用DBGrid1DrawColumnCell事件
      break;
    end;
  end;
end;

procedure TfrmMain.SpeedButton1Click(Sender: TObject);
var
  i:integer;
begin
  for i:=LOW(ArCheckBoxValue) to HIGH(ArCheckBoxValue) do
  begin
    ArCheckBoxValue[I,0]:=1;
  end;
  DBGrid1.Refresh;//调用DBGrid1DrawColumnCell事件
end;

procedure TfrmMain.SpeedButton2Click(Sender: TObject);
var
  i:integer;
begin
  for i:=LOW(ArCheckBoxValue) to HIGH(ArCheckBoxValue) do
  begin
    ArCheckBoxValue[I,0]:=0;
  end;
  DBGrid1.Refresh;//调用DBGrid1DrawColumnCell事件
end;

procedure TfrmMain.DateTimePicker1Change(Sender: TObject);
begin
  UpdateEquipAdoquery;//ADOQuery1.Requery;
end;

procedure TfrmMain.DateTimePicker2Change(Sender: TObject);
begin
  UpdateEquipAdoquery;//ADOQuery1.Requery;
end;

procedure TfrmMain.LabeledEdit1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key<>13 then EXIT;

  UpdateEquipAdoquery;//ADOQuery1.Requery;

  if (Sender as TLabeledEdit).CanFocus then begin (Sender as TLabeledEdit).SetFocus;(Sender as TLabeledEdit).SelectAll; end;
end;

end.
