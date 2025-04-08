unit uProducaoItens;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils;

Type
  TProducaoItens = class(TInterfacedObject, iEntidade)
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

{ TProducao }

constructor TProducaoItens.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL(
    'Select PI.*, P.NOME_PROD, P.UNIDADE ' +
    'from PRODUCAO_ITENS PI ' +
    'Join PRODUTOS P On (P.COD_PROD = PI.COD_INSUMO) ' +
    'Where PI.ID_PRODUCAO = :pID_Producao');
  InicializaDataSource;
end;

destructor TProducaoItens.Destroy;
begin
  inherited;
end;

class function TProducaoItens.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TProducaoItens.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TProducaoItens.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  //FEntidadeBase.Iquery.IndexFieldNames('');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
  FEntidadeBase.SetReadOnly(Value, 'nome_prod', False);
  FEntidadeBase.SetReadOnly(Value, 'unidade', False);
end;

function TProducaoItens.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.SQL(
    'Select PI.*, P.NOME_PROD, P.UNIDADE ' +
    'from PRODUCAO_ITENS PI ' +
    'Join PRODUTOS P On (P.COD_PROD = PI.COD_INSUMO) ' +
    'Where 1 <> 1');
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TProducaoItens.ModificaDisplayCampos;
begin

end;

function TProducaoItens.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
