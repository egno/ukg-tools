program tsql;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, SysUtils, CustApp,
  mssqlconn, sqldb, db
  { you can add units after this };

type

  { exportdsoft }

  exportdsoft = class(TCustomApplication)
  private
    Conn: TMSSQLConnection;
    DataSource: TDataSource;
    Tran: TSQLTransaction;
    procedure ExecuteSQL(f: String);
  protected
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure WriteHelp; virtual;
  end;

{ exportdsoft }


procedure exportdsoft.ExecuteSQL(f: String);
var
  Query: TSQLQuery;
begin
  try
    Conn.Connected:=true;
    writeln('Connected.');
    Query := TSQLQuery.Create(Conn);
    Query.DataSource := DataSource;
    Query.Transaction := Conn.Transaction;
    Conn.Transaction.StartTransaction;
    Query.SQL.LoadFromFile(f);
//    writeln('Execute: ' + Query.SQL.Text);
    Query.ExecSQL;
    Conn.Transaction.Commit;
    writeln('File ' + f + ' was done.')
  except
    on E: Exception do
      ShowException(E);
  end;
  Query.Close;
  Conn.Transaction.EndTransaction;
  Query.Free;
  Query := nil;
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

  if not HasOption('f','file') then begin
    Terminate;
    Exit;
  end;

  writeln('Host:', Conn.HostName);
  writeln('Params:', Conn.Params.CommaText);
  writeln('Base:', Conn.DatabaseName);
  writeln('User:', Conn.UserName);

  ExecuteSQL(GetOptionValue('f','file'));

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
  DataSource := TDataSource.Create(Conn);
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

