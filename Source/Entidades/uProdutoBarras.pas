unit uProdutoBarras;

interface

uses
  Model.Entidade.Interfaces, Data.DB,  SysUtils, Dialogs;
Type
  TProdutoBarras = class(TInterfacedObject, iEntidade)
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

{ TProdutoBarras }

constructor TProdutoBarras.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL(
    'select pb.*, p.nome_prod, p.cod_barra as barra_principal ' +
    'from PRODUTOS_BARRAS pb ' +
    'join PRODUTOS p On (p.COD_PROD = pb.COD_PROD) ' +
    'where pb.COD_PROD = :pCod_Prod');

  InicializaDataSource;
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
  if Value = nil then
    Value:= FEntidadeBase.DataSource;

  FEntidadeBase.Iquery.IndexFieldNames('COD_BARRA');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;

  ShowMessage(inttostr( Value.DataSet.RecordCount));


end;

function TProdutoBarras.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;

  FEntidadeBase.AddParametro('pCod_Prod', -1);
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL + ' and 1 <> 1');
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TProdutoBarras.ModificaDisplayCampos;
begin

end;

function TProdutoBarras.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
