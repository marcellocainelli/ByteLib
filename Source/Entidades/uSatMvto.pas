unit uSatMvto;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils, Byte.Lib;

Type
  TSatMvto = class(TInterfacedObject, iEntidade)
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

{ TSatMvto }

constructor TSatMvto.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TipoPesquisa(0);
  FEntidadeBase.TextoSQL('Select * from SAT_MOVIMENTO Where (1 = 1) ');
  InicializaDataSource;
end;

destructor TSatMvto.Destroy;
begin
  inherited;
end;

class function TSatMvto.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TSatMvto.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TSatMvto.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSQL:= FEntidadeBase.TextoSql;
  case FEntidadeBase.TipoPesquisa of
    0: vTextoSQL:= vTextoSql + 'and ID = :Parametro';
    1: vTextoSQL:= vTextoSql + 'and NUM_CUPOM = :Parametro';
    2: vTextoSQL:= vTextoSql + 'and DTEMISSAO = :Parametro';
    3: vTextoSQL:= vTextoSql + 'and NOME Containing :Parametro';
  end;
  FEntidadeBase.AddParametro('Parametro', FEntidadeBase.TextoPesquisa, ftString);
  FEntidadeBase.Iquery.IndexFieldNames('ID');
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TSatMvto.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.IndexFieldNames('ID');
  FEntidadeBase.AddParametro('Parametro', '-1', ftString);
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSql + ' and ID = :Parametro');
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TSatMvto.ModificaDisplayCampos;
begin
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('VRICMS')).currency:= True;
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('VRTOTALPRODUTOS')).currency:= True;
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('DESCONTO')).currency:= True;
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('OUTROS')).currency:= True;
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('VRTOTALNOTA')).currency:= True;
end;

function TSatMvto.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
