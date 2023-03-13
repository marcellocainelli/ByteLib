unit uProdutoLote;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils;

Type
  TProdutoLote = class(TInterfacedObject, iEntidade)
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

{ TProdutoLote }

constructor TProdutoLote.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('select * from ESTOQUEFILIAL_LOTE where COD_FILIAL = :pCod_Filial and COD_PROD = :pCod_prod');

  InicializaDataSource;
end;

destructor TProdutoLote.Destroy;
begin
  inherited;
end;

class function TProdutoLote.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TProdutoLote.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TProdutoLote.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.IndexFieldNames('LOTE');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TProdutoLote.InicializaDataSource(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;

  vTextoSql:= 'Select * From ESTOQUEFILIAL_LOTE Where 1 <> 1';
  FEntidadeBase.Iquery.SQL(vTextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TProdutoLote.ModificaDisplayCampos;
begin
  TDateField(FEntidadeBase.Iquery.Dataset.FieldByName('dt_fabricacao')).EditMask:= '!99/99/00;1;_';
  TDateField(FEntidadeBase.Iquery.Dataset.FieldByName('validade')).EditMask:= '!99/99/00;1;_';
end;

function TProdutoLote.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
