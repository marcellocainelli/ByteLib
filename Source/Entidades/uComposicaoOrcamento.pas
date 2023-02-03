unit uComposicaoOrcamento;

interface

uses
  Model.Entidade.Interfaces, Data.DB, uLib, System.SysUtils, StrUtils;

Type
  TComposicaoOrcamento = class(TInterfacedObject, iEntidade)
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

{ TComposicaoOrcamento }

constructor TComposicaoOrcamento.Create;
begin
//    'Select pe.*, p.nome_prod, p.unidade ' +
//    'From PEDIDO_COMPOSICAO pe ' +
//    'join produtos p on (p.cod_prod = pe.cod_kit) ' +
//    'where pe.id_pedido = :pIdPedido ');

  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL(
    'Select pe.* From PEDIDO_COMPOSICAO pe where pe.id_pedido = :pIdPedido ');
  InicializaDataSource;
end;

destructor TComposicaoOrcamento.Destroy;
begin
  inherited;
end;

class function TComposicaoOrcamento.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TComposicaoOrcamento.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TComposicaoOrcamento.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.IndexFieldNames('ID');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
//  FEntidadeBase.SetReadOnly(Value, 'NOME_PROD', False);
//  FEntidadeBase.SetReadOnly(Value, 'UNIDADE', False);
end;

function TComposicaoOrcamento.InicializaDataSource(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSql:= 'Select * From PEDIDO_COMPOSICAO Where 1 <> 1';
  FEntidadeBase.Iquery.SQL(vTextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TComposicaoOrcamento.ModificaDisplayCampos;
begin

end;

function TComposicaoOrcamento.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
