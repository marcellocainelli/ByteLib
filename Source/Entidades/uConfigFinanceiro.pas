unit uConfigFinanceiro;

interface

uses
  Model.Entidade.Interfaces, Data.DB;
Type
  TConfigFinanceiro = class(TInterfacedObject, iEntidade)
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

{ TConfigFinanceiro }

constructor TConfigFinanceiro.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('select * from config_financeiro where id = 1');

  InicializaDataSource;
end;

destructor TConfigFinanceiro.Destroy;
begin

  inherited;
end;

class function TConfigFinanceiro.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TConfigFinanceiro.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TConfigFinanceiro.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;

  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSql);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TConfigFinanceiro.InicializaDataSource(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSql:= 'Select * From config_financeiro Where 1 <> 1';
  FEntidadeBase.Iquery.SQL(vTextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TConfigFinanceiro.ModificaDisplayCampos;
begin
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('pagar_limite_diario')).currency:= True;
end;

function TConfigFinanceiro.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
