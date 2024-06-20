unit uProdInfoNutricional;

interface
uses
  System.SysUtils,
  Data.DB,
  Model.Entidade.Interfaces;
Type
  TProdInfoNutricional = class(TInterfacedObject, iEntidade)
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
{ TGrupo }
constructor TProdInfoNutricional.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('select * from PROD_INFO_NUTRICIONAL where (1 = 1) ');
  InicializaDataSource;
end;
destructor TProdInfoNutricional.Destroy;
begin
  inherited;
end;
class function TProdInfoNutricional.New: iEntidade;
begin
  Result:= Self.Create;
end;
function TProdInfoNutricional.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;
function TProdInfoNutricional.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSQL:= FEntidadeBase.TextoSQL;
  case FEntidadeBase.TipoPesquisa of
    1: vTextoSQL:= vTextoSQL + ' and COD_PROD = :pCod_Prod';
  end;
//  FEntidadeBase.Iquery.IndexFieldNames('DESCRICAO');
  FEntidadeBase.Iquery.SQL(vTextoSql);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;
function TProdInfoNutricional.InicializaDataSource(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSQL:= FEntidadeBase.TextoSQL;
//  FEntidadeBase.Iquery.IndexFieldNames('DESCRICAO');
  FEntidadeBase.Iquery.SQL(vTextoSql);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;
procedure TProdInfoNutricional.ModificaDisplayCampos;
begin
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('CARBOIDRATOS')).DisplayFormat:= '#,0.0';
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('ACUCARES_TOTAIS')).DisplayFormat:= '#,0.0';
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('ACUCARES_ADICIONADOS')).DisplayFormat:= '#,0.0';
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('PROTEINAS')).DisplayFormat:= '#,0.0';
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('GORDURAS_TOTAIS')).DisplayFormat:= '#,0.0';
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('GORDURAS_SATURADAS')).DisplayFormat:= '#,0.0';
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('GORDURAS_TRANS')).DisplayFormat:= '#,0.0';
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('FIBRA_ALIMENTAR')).DisplayFormat:= '#,0.0';
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('SODIO')).DisplayFormat:= '#,0.0';
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('LACTOSE')).DisplayFormat:= '#,0.0';
end;
function TProdInfoNutricional.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;
end.
