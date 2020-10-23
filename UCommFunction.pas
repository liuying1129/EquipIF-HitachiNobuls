unit UCommFunction;

interface
uses SysUtils,ADODB,Dialogs;

function ShowOptionForm(const pCaption,pTabSheetCaption,pItemInfo,pInifile:Pchar):boolean;stdcall;external 'OptionSetForm.dll';
function DeCryptStr(aStr: Pchar; aKey: Pchar): Pchar;stdcall;external 'DESCrypt.dll';//½âÃÜ
procedure WriteLog(const ALogStr: Pchar);stdcall;external 'LYFunction.dll';
function ExecSQLCmd(AConnectionString:string;ASQL:string):integer;
function ScalarSQLCmd(AConnectionString:string;ASQL:string):string;

implementation

function ExecSQLCmd(AConnectionString:string;ASQL:string):integer;
var
  Conn:TADOConnection;
  Qry:TAdoQuery;
begin
  Conn:=TADOConnection.Create(nil);
  Conn.LoginPrompt:=false;
  Conn.ConnectionString:=AConnectionString;
  Qry:=TAdoQuery.Create(nil);
  Qry.Connection:=Conn;
  Qry.Close;
  Qry.SQL.Clear;
  Qry.SQL.Text:=ASQL;
  Try
    Result:=Qry.ExecSQL;
  except
    on E:Exception do
    begin
      WriteLog(pchar('º¯ÊýExecSQLCmdÊ§°Ü:'+E.Message+'¡£´íÎóµÄSQL:'+ASQL));
      MESSAGEDLG('º¯ÊýExecSQLCmdÊ§°Ü:'+E.Message+'¡£´íÎóµÄSQL:'+ASQL,mtError,[mbOK],0);
      Result:=-1;
    end;
  end;
  Qry.Free;
  Conn.Free;
end;

function ScalarSQLCmd(AConnectionString:string;ASQL:string):string;
var
  Conn:TADOConnection;
  Qry:TAdoQuery;
begin
  Result:='';
  Conn:=TADOConnection.Create(nil);
  Conn.LoginPrompt:=false;
  Conn.ConnectionString:=AConnectionString;
  Qry:=TAdoQuery.Create(nil);
  Qry.Connection:=Conn;
  Qry.Close;
  Qry.SQL.Clear;
  Qry.SQL.Text:=ASQL;
  Try
    Qry.Open;
  except
    on E:Exception do
    begin
      WriteLog(pchar('º¯ÊýScalarSQLCmdÊ§°Ü:'+E.Message+'¡£´íÎóµÄSQL:'+ASQL));
      MESSAGEDLG('º¯ÊýScalarSQLCmdÊ§°Ü:'+E.Message+'¡£´íÎóµÄSQL:'+ASQL,mtError,[mbOK],0);
      Qry.Free;
      Conn.Free;
      exit;
    end;
  end;
  Result:=Qry.Fields[0].AsString;
  Qry.Free;
  Conn.Free;
end;

end.
