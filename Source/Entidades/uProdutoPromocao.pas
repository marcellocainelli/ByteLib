unit uProdutoPromocao;

interface

uses
  Model.Entidade.Interfaces, Data.DB, uLib, System.SysUtils, StrUtils;

Type
  TProdutoPromocao = class(TInterfacedObject, iEntidade)
    private
      FEntidadeBase: iEntidadeBase<iEntidade>;
    public
      constructor Create;
      destructor Destroy; override;
      class function New: iEntidade;
      function EntidadeBase: iEntidadeBase<iEntidade>;
      function Consulta(Value: TDataSource): iEntidade;
      function InicializaDataSource(Value: TDataSource): iEntidade;
      procedure ModificaDisplayCampos;
  end;

implementation

uses
  uEntidadeBase;

{ TProdutoPromocao }

constructor TProdutoPromocao.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('Select PP.*, P.NOME_PROD From PRODUTOS_PROMOCAO PP Join PRODUTOS P On (P.COD_PROD = PP.COD_PROD)');
end;

destructor TProdutoPromocao.Destroy;
begin
  inherited;
end;

class function TProdutoPromocao.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TProdutoPromocao.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TProdutoPromocao.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  vTextoSQL:= FEntidadeBase.TextoSql;
  case FEntidadeBase.TipoPesquisa of
    0: vTextoSQL:= vTextoSQL + ' where PP.COD_PROD = :pParametro';
    1: vTextoSQL:= vTextoSQL + ' where P.NOME_PROD containing :pParametro';
  end;
  FEntidadeBase.Iquery.IndexFieldNames('NOME_PROD');
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TProdutoPromocao.InicializaDataSource(Value: TDataSource): iEntidade;
begin

end;

procedure TProdutoPromocao.ModificaDisplayCampos;
begin
  TDateField(FEntidadeBase.Iquery.Dataset.FieldByName('dtinicio')).EditMask:= '!99/99/00;1;_';
  TDateField(FEntidadeBase.Iquery.Dataset.FieldByName('dtfim')).EditMask:= '!99/99/00;1;_';
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('preco')).currency:= True;

  //TStringField(FEntidadeBase.Iquery.Dataset.FieldByName('NOME_PROD')).ProviderFlags:= [];
end;

end.
