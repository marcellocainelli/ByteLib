unit uDmConn;

interface

uses
  System.SysUtils, System.Classes, Model.Conexao.Interfaces,
  Controller.Factory.Connection;

type
  TdmConn = class(TDataModule)
    procedure DataModuleCreate(Sender: TObject);
  private
    FConnection: iConexao;
    function GetConnection: iConexao;
    procedure SetConnection(const Value: iConexao);
  public
    property Connection: iConexao read GetConnection write SetConnection;
  end;

var
  dmConn: TdmConn;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

{ TdmConn }

procedure TdmConn.DataModuleCreate(Sender: TObject);
begin
  FConnection:= TControllerFactoryConn.New.Conn(FDConn);
end;

function TdmConn.GetConnection: iConexao;
begin
{$IFDEF SERVER}
  Result:= nil;
{$ELSE}
  Result:= FConnection;
{$ENDIF}
end;

procedure TdmConn.SetConnection(const Value: iConexao);
begin
  FConnection:= Value;
end;


initialization
{$IFNDEF SERVER}
  dmConn:= TdmConn.Create(nil);
{$ENDIF}
finalization
{$IFNDEF SERVER}
  FreeAndNil(dmConn);
{$ENDIF}
end.
