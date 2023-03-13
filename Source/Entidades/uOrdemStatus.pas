unit uOrdemStatus;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils;

Type
  TOrdemStatus = class(TInterfacedObject, iEntidade)
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

{ TOrdemStatus }

constructor TOrdemStatus.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('Select CODIGO, STATUS From ORD_STATUS');

  InicializaDataSource;
end;

destructor TOrdemStatus.Destroy;
begin
  inherited;
end;

class function TOrdemStatus.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TOrdemStatus.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TOrdemStatus.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.IndexFieldNames('STATUS');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TOrdemStatus.InicializaDataSource(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;

  vTextoSql:= 'Select * From ORD_STATUS Where 1 <> 1';
  FEntidadeBase.Iquery.SQL(vTextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TOrdemStatus.ModificaDisplayCampos;
begin

end;

function TOrdemStatus.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
