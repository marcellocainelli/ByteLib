unit uOrc_Status;

interface

uses
  Model.Entidade.Interfaces, Data.DB, uLib, System.SysUtils;
Type
  TOrc_Status = class(TInterfacedObject, iEntidade)
  private
    FEntidadeBase: iEntidadeBase<iEntidade>;
  public
    constructor Create;
    destructor Destroy; override;
    class function New: iEntidade;
    function EntidadeBase: iEntidadeBase<iEntidade>;
    function Consulta(Value: TDataSource = nil): iEntidade;
    function InicializaDataSource(Value: TDataSource = nil): iEntidade;
    function DtSrc: TDataSource;
    procedure ModificaDisplayCampos;
  end;
implementation
uses
  uEntidadeBase;

{ TOrc_Status }

constructor TOrc_Status.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('Select * from ORC_STATUS');
  InicializaDataSource;
end;

destructor TOrc_Status.Destroy;
begin
  inherited;
end;

class function TOrc_Status.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TOrc_Status.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TOrc_Status.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TOrc_Status.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.SQL('Select * From ORC_STATUS Where 1 <> 1');
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TOrc_Status.ModificaDisplayCampos;
begin

end;

function TOrc_Status.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
