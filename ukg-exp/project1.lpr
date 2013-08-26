program project1;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, SysUtils, CustApp,
  mssqlconn, sqldb
  { you can add units after this };

type

  { exportdsoft }

  exportdsoft = class(TCustomApplication)
  private
    Conn: TMSSQLConnection;
    Tran: TSQLTransaction;
    procedure ExecuteSQL(SQL: String);
  protected
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure WriteHelp; virtual;
  end;

{ exportdsoft }


procedure exportdsoft.ExecuteSQL(SQL: String);
begin
  try
    Conn.Connected:=true;
    writeln('Connected.');
    Conn.Transaction.StartTransaction;
    writeln('Execute: '+ SQL);
    Conn.Transaction.Commit;
  except
    on E: Exception do
      ShowException(E);
  end;
  Conn.Transaction.EndTransaction;
end;

procedure exportdsoft.DoRun;
var
  ErrorMsg: String;
begin
  // quick check parameters
  ErrorMsg:=CheckOptions('hs:P:d:u:p:q:f:','help server: port: database: user: password: query: file:');
  if ErrorMsg<>'' then begin
    ShowException(Exception.Create(ErrorMsg));
    Terminate;
    Exit;
  end;

  // parse parameters
  if HasOption('h','help') then begin
    WriteHelp;
    Terminate;
    Exit;
  end;

  { add your program here }
  if HasOption('s','server') then
    Conn.HostName:= GetOptionValue('s','server') ;

  if HasOption('P','port') then begin
    Conn.Params.Clear;
    Conn.Params.Add('port='+GetOptionValue('p','port'));
  end;

  if HasOption('d','database') then
    Conn.DatabaseName:=GetOptionValue('d','database');

  if HasOption('u','user') then
    Conn.UserName:=GetOptionValue('u','user');

  if HasOption('p','password') then
    Conn.Password:=GetOptionValue('p','password');

  if HasOption('f','file') then
    Conn.Password:=GetOptionValue('p','password');

  writeln('Host:', Conn.HostName);
  writeln('Params:', Conn.Params.CommaText);
  writeln('Base:', Conn.DatabaseName);
  writeln('User:', Conn.UserName);

  ExecuteSQL('select');

  // stop program loop
  Terminate;
end;

constructor exportdsoft.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  StopOnException:=True;
  Conn := TMSSQLConnection.Create(Self);
  Tran := TSQLTransaction.Create(Conn);
  Conn.Transaction:=Tran;
  Conn.HostName:='localhost';
end;

destructor exportdsoft.Destroy;
begin

  inherited Destroy;
end;

procedure exportdsoft.WriteHelp;
begin
  { add your help code here }
  writeln('Usage: ',ExeName,' -h');
end;

var
  Application: exportdsoft;
begin
  Application:=exportdsoft.Create(nil);
  Application.Title:='Export into DSoft Database';
  Application.Run;
  Application.Free;
end.

