unit uProdutoBarras;

interface

uses
  Model.Entidade.Interfaces, Data.DB;

Type
  TProdutoBarras = class(TInterfacedObject, iEntidade)
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

{ TProdutoBarras }

constructor TProdutoBarras.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL(
    'select pb.*, p.nome_prod, p.cod_barra as barra_principal ' +
    'from PRODUTOS_BARRAS pb ' +
    'join PRODUTOS p On (p.COD_PROD = pb.COD_PROD) ' +
    'where pb.COD_PROD = :pCod_Prod');
end;

destructor TProdutoBarras.Destroy;
begin

  inherited;
end;

class function TProdutoBarras.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TProdutoBarras.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TProdutoBarras.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  FEntidadeBase.Iquery.IndexFieldNames('COD_BARRA');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TProdutoBarras.InicializaDataSource(Value: TDataSource): iEntidade;
begin

end;

procedure TProdutoBarras.ModificaDisplayCampos;
begin

end;

end.
