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
  sCryptSeed='lc';//�ӽ�������
  SYSNAME='PEIS'; 

var
  PeisConnStr:String;
  EquipConnStr:String;

{$R *.dfm}

function GetConnectString(const ADB:string):string;
//ADB:PEIS���ݿ⡢�豸���ݿ�
var
  Ini:tinifile;
  userid, password, datasource, initialcatalog: string;
  ifIntegrated:boolean;//�Ƿ񼯳ɵ�¼ģʽ

  pInStr,pDeStr:Pchar;
  i:integer;
begin
  result:='';
  
  Ini := tinifile.Create(ChangeFileExt(Application.ExeName,'.INI'));
  datasource := Ini.ReadString(ADB, '������', '');
  initialcatalog := Ini.ReadString(ADB, '���ݿ�', '');
  ifIntegrated:=ini.ReadBool(ADB,'���ɵ�¼ģʽ',false);
  userid := Ini.ReadString(ADB, '�û�', '');
  password := Ini.ReadString(ADB, '����', '107DFC967CDCFAAF');
  Ini.Free;
  //======����password
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
  //Persist Security Info,��ʾADO�����ݿ����ӳɹ����Ƿ񱣴�������Ϣ
  //ADOȱʡΪTrue,ADO.netȱʡΪFalse
  //�����лᴫADOConnection��Ϣ��TADOLYQuery,������ΪTrue
  result := result + 'Persist Security Info=True;';
  if ifIntegrated then
    result := result + 'Integrated Security=SSPI;';
end;

function TfrmMain.MakeDBConn(const ADB:string;AADOConn:TADOConnection): boolean;
//ADB:PEIS���ݿ⡢�豸���ݿ�
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
    if ADB='PEIS���ݿ�' then PeisConnStr:=newconnstr;
    if ADB='�豸���ݿ�' then EquipConnStr:=newconnstr;
  except
  end;
  if not result then
  begin
    ss:='������'+#2+'Edit'+#2+#2+'0'+#2+#2+#3+
        '���ݿ�'+#2+'Edit'+#2+#2+'0'+#2+#2+#3+
        '���ɵ�¼ģʽ'+#2+'CheckListBox'+#2+#2+'0'+#2+#2+#3+
        '�û�'+#2+'Edit'+#2+#2+'0'+#2+#2+#3+
        '����'+#2+'Edit'+#2+#2+'0'+#2+#2+'1';
    if ShowOptionForm('�������ݿ�',Pchar(ADB),Pchar(ss),Pchar(ChangeFileExt(Application.ExeName,'.ini'))) then
      goto labReadIni else application.Terminate;
  end;
end;

procedure TfrmMain.UpdateEquipAdoquery;
var
  ss1:string;
begin
  ss1:='SELECT TOP 1000 '+
      'P.PatientName as ���� '+
      ',P.PatientAge as ���� '+
      ',CASE UPPER(P.PatientSex) WHEN ''M'' THEN ''��'' when ''F'' THEN ''Ů'' else ''δ֪'' end as �Ա� '+
      ',P.CreateDateTime as ����ʱ�� '+
      ',O.ClinicDepartment as �ͼ���� '+
      ',O.ClinicDoctor as �ͼ�ҽ�� '+
      ',SR.StudyHint as �����ʾ '+
      ',SR.StudySee as ������� '+
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

      ',PS.SendSuccNum '+// AS ���ͳɹ�����
      //',PS.LastSendDes AS �������� '+
      //',PS.LastSendTime AS �����ʱ�� '+

  'FROM T_Patient P '+
  'LEFT JOIN T_Order O ON O.PatientIdentity=P.PatientIdentity '+
  'LEFT JOIN T_Study S ON S.OrderIdentity=O.OrderIdentity '+
  'LEFT JOIN T_StudyResult SR ON SR.StudyIdentity=S.StudyIdentity '+
  'LEFT JOIN PEIS_Send PS ON PS.StudyResultIdentity=SR.StudyResultIdentity '+
  ' where S.StudyState=''�Ѵ�ӡ'' '+//ֻ��ѯ����ɱ��浥
  ' and O.ClinicDepartment=''���'' '+//ֻ��ѯ��챨�浥(�������=���)
  ' and P.PatientName is not null and P.PatientName<>'''' '+//������������
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
  MakeDBConn('�豸���ݿ�',ADOConnEquip);
  MakeDBConn('PEIS���ݿ�',ADOConnPEIS);

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
  jcts_itemid:string;//�������ʾ����Ŀ����
  jcjl_itemid:string;//�������ۡ���Ŀ����
  jcjy_itemid:string;//����齨�顿��Ŀ����
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
    MESSAGEDLG('�޷�������!',mtError,[MBOK],0);
    exit;
  end;
  Eqip_Jcts:=ADOQuery1.fieldbyname('�����ʾ').AsString;
  if trim(Eqip_Jcts)='' then
  begin
    MESSAGEDLG('�����ʾΪ��!',mtError,[MBOK],0);
    exit;
  end;
  if ADOQuery2.RecordCount<=0 then
  begin
    MESSAGEDLG('PEIS�޸��ܼ���!',mtError,[MBOK],0);
    exit;
  end;
  if ADOQuery2.RecordCount>1 then
  begin
    MESSAGEDLG('���ܼ�����PEIS�ж�����¼!',mtError,[MBOK],0);
    exit;
  end;
  if ADOQuery2.FieldByName('�����').AsString<>'' then
  begin
    MESSAGEDLG('���ܼ�����PEIS�����!',mtError,[MBOK],0);
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
    MESSAGEDLG('�����ڲʳ��������ʾ����Ŀ(�����ֶ�5=3).�����Ա�����Ŀ����!',mtError,[MBOK],0);
    adotemp3.Free;
    exit;
  end;
  if adotemp3.RecordCount>1 then
  begin
    MESSAGEDLG('���ڶ����ʳ��������ʾ����Ŀ(�����ֶ�5=3).�����Ա�����Ŀ����!',mtError,[MBOK],0);
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
    MESSAGEDLG('�����ڡ������ۡ���Ŀ(�����ֶ�5=1).�����Ա�����Ŀ����!',mtError,[MBOK],0);
    adotemp4.Free;
    exit;
  end;
  if adotemp4.RecordCount>1 then
  begin
    MESSAGEDLG('���ڶ����������ۡ���Ŀ(�����ֶ�5=1).�����Ա�����Ŀ����!',mtError,[MBOK],0);
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
    MESSAGEDLG('�����ڡ���齨�顿��Ŀ(�����ֶ�5=2).�����Ա�����Ŀ����!',mtError,[MBOK],0);
    adotemp5.Free;
    exit;
  end;
  if adotemp5.RecordCount>1 then
  begin
    MESSAGEDLG('���ڶ�������齨�顿��Ŀ(�����ֶ�5=2).�����Ա�����Ŀ����!',mtError,[MBOK],0);
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
    //if (MessageDlg('PEIS���ڼ������,������ԭ�м������,ȷ����', mtConfirmation, [mbYes, mbNo], 0) <> mrYes) then exit;
    ExecSQLCmd(PeisConnStr,'update chk_valu set itemvalue='''+Eqip_Jcts+''' where pkunid='+Peis_Unid+' and itemid='''+jcts_itemid+''' ');
  end;

  adotemp555:=tadoquery.Create(nil);
  adotemp555.Connection:=ADOConnPEIS;
  adotemp555.Close;
  adotemp555.SQL.Clear;
  adotemp555.SQL.Text:='select name,Reserve2 from CommCode where TypeName=''�쳣����'' ';
  adotemp555.Open;

  RegEx := TPerlRegEx.Create;
  RegEx.Subject := Eqip_Jcts;
  RegEx.RegEx   := '��|��';//��|�ָ�����ָ���.������ʽ|��ʾ"��"
  Eqip_Jcts_List:=TStringList.Create;
  RegEx.Split(Eqip_Jcts_List,MaxInt);//MaxInt,��ʾ�ֶܷ��پͷֶ���
  FreeAndNil(RegEx);
  for i :=0  to Eqip_Jcts_List.Count-1 do
  begin
    if pos('δ�������쳣',Eqip_Jcts_List[i])>0 then continue;
    
    //���ɼ�����begin
    //ɾ�������ʾ�е����(��1��23��)
    RegEx2 := TPerlRegEx.Create;
    RegEx2.Subject := Eqip_Jcts_List[i];
    RegEx2.RegEx   := '\d{1,2}��';
    RegEx2.Replacement:='';
    RegEx2.ReplaceAll;
    Eqip_Jcts2:=RegEx2.Subject;
    FreeAndNil(RegEx2);
    if trim(Eqip_Jcts2)<>'' then Peis_Jcjl:=Peis_Jcjl+Eqip_Jcts2+'��'+#13;//������
    //���ɼ�����end

    //���ɼ�齨��begin
    adotemp555.First;
    while not adotemp555.Eof do
    begin
      //ƥ���쳣�ؼ���
      RegEx3 := TPerlRegEx.Create;
      RegEx3.Subject := Eqip_Jcts_List[i];
      RegEx3.RegEx   := adotemp555.fieldbyname('name').AsString;
      b3:=RegEx3.Match;
      FreeAndNil(RegEx3);
      if b3 then Peis_Jcjy:=Peis_Jcjy+adotemp555.fieldbyname('Reserve2').AsString+#13;
      adotemp555.Next;
    end;
    //���ɼ�齨��end
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

  BitBtn2Click(BitBtn2);//����ˢ���ѷ��͵���ɫ

  MESSAGEDLG('�������!',mtInformation,[MBOK],0);
end;

procedure TfrmMain.ADOQuery1AfterScroll(DataSet: TDataSet);
var
  ss1:string;
begin
    	ss1:='select cc.patientname as ����,cc.age as ����,cc.sex as �Ա�,cc.check_date as �������,cc.report_doctor as �����,cc.combin_id as ������,cc.Caseno as ������,cc.deptname as �ͼ����,cc.check_doctor as �ͼ�ҽ��,cc.unid '+
    	' from chk_con cc,CommCode cco '+
    	' where cco.TypeName=''�������'' and cco.SysName='''+SYSNAME+
      ''' and cc.combin_id=cco.name '+
      ' AND cc.patientname='''+ADOQuery1.FieldByName('����').AsString+
    	''' and isnull(cc.sex,'''')='''+ADOQuery1.FieldByName('�Ա�').AsString+
    	''' and dbo.uf_GetAgeReal(cc.age)=dbo.uf_GetAgeReal('''+ADOQuery1.FieldByName('����').AsString+''') ';

    ADOQuery2.Close;
    ADOQuery2.SQL.Clear;
    ADOQuery2.SQL.Text:=SS1;
    ADOQuery2.Open;

  //���½������
  Memo1.Lines.Text:=DataSet.fieldbyname('����').AsString+
              ' '+
              DataSet.fieldbyname('����').AsString+
              ' '+
              DataSet.fieldbyname('�Ա�').AsString+
              ' '+
              FormatDateTime('YYYY-MM-DD',DataSet.fieldbyname('����ʱ��').AsDateTime)+
              #13#13+
              DataSet.fieldbyname('�����ʾ').AsString;
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

  //���½������
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
      '(case cv.issure when 1 then ''��'' else '''' end) as ��,'+
      ' cv.Name as ����,cv.english_name as Ӣ����,cv.itemvalue as ���,cv.Min_value as ��Сֵ,cv.Max_value as ���ֵ,cv.Unit as ��λ,cv.pkcombin_id,cv.combin_Name,cv.pkunid,cv.valueid '+
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
  //���½������
  Memo2.Lines.Text:=DataSet.fieldbyname('���').AsString;
  Label2.Caption:=DataSet.fieldbyname('����').AsString;
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
  //���͹��������б仯��ɫ
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
