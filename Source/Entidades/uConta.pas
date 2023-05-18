unit uConta;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils;

Type
  TConta = class(TInterfacedObject, iEntidade)
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

{ TConta }

constructor TConta.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('select C.*, C.CONTA as CODIGO, 0 as INDICE '+
                         'from CADBAN C '+
                         'where C.COD_FILIAL = :CodFilial');

  InicializaDataSource;
end;

destructor TConta.Destroy;
begin

  inherited;
end;

class function TConta.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TConta.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TConta.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSQL:= FEntidadeBase.TextoSQL;
  If FEntidadeBase.RegraPesquisa = 'Contendo' then
    FEntidadeBase.RegraPesquisa('Containing')
  else If FEntidadeBase.RegraPesquisa = 'Início do texto' then
    FEntidadeBase.RegraPesquisa('Starting With')
  else begin
    FEntidadeBase.RegraPesquisa('Containing');
    FEntidadeBase.TipoPesquisa(1);
  end;
  Case FEntidadeBase.TipoPesquisa of
    0: vTextoSQL:= vTextoSQL + ' and C.CONTA = :Parametro';
    1: vTextoSQL:= vTextoSQL + ' and Upper(C.BANCO) ' + FEntidadeBase.RegraPesquisa + ' Upper(:Parametro)';
  end;
  if not FEntidadeBase.Inativos then
    vTextoSQL:= vTextoSQL + ' and C.STATUS = ''A''';
  FEntidadeBase.AddParametro('Parametro', FEntidadeBase.TextoPesquisa, ftString);
  FEntidadeBase.Iquery.IndexFieldNames('BANCO');
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TConta.InicializaDataSource(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSql:= 'Select * From CADBAN Where 1 <> 1';
  FEntidadeBase.Iquery.SQL(vTextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TConta.ModificaDisplayCampos;
begin
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('LIMITE_CREDITO')).DisplayFormat:= '#,0.00';
end;

function TConta.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
