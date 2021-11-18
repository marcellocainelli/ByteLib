unit uProdutoLote;

interface

uses
  Model.Entidade.Interfaces, Data.DB, uLib, System.SysUtils;

Type
  TProdutoLote = class(TInterfacedObject, iEntidade)
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

{ TProdutoLote }

constructor TProdutoLote.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('select * from ESTOQUEFILIAL_LOTE where COD_FILIAL = :pCod_Filial and COD_PROD = :pCod_prod');
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
  FEntidadeBase.Iquery.IndexFieldNames('LOTE');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TProdutoLote.InicializaDataSource(Value: TDataSource): iEntidade;
begin

end;

procedure TProdutoLote.ModificaDisplayCampos;
begin
  TDateField(FEntidadeBase.Iquery.Dataset.FieldByName('validade')).EditMask:= '!99/99/00;1;_';
end;

end.
