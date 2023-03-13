unit uNfse_CodTributacao;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils;
Type
  TNfse_CodTributacao = class(TInterfacedObject, iEntidade)
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

{ TNfse_CodTributacao }

constructor TNfse_CodTributacao.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('select * from NFSERVICO_CODIGOTRIBUTACAO');

  InicializaDataSource;
end;

destructor TNfse_CodTributacao.Destroy;
begin
  inherited;
end;

class function TNfse_CodTributacao.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TNfse_CodTributacao.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TNfse_CodTributacao.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.IndexFieldNames('CODIGO');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TNfse_CodTributacao.InicializaDataSource(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSql:= 'Select * From NFSERVICO_CODIGOTRIBUTACAO Where 1 <> 1';
  FEntidadeBase.Iquery.SQL(vTextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TNfse_CodTributacao.ModificaDisplayCampos;
begin
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('aliquota')).DisplayFormat:= '#,0.000';
end;

function TNfse_CodTributacao.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
