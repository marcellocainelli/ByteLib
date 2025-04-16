unit uRequisicaoCompra;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils;
Type
  TRequisicaoCompra = class(TInterfacedObject, iEntidade)
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

{ TRequisicaoCompra }

constructor TRequisicaoCompra.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL(
    'select RC.*, F.NOME, T.NOME as TRANSPORTADORA ' +
    'from REQUISICAO_COMPRA RC ' +
    'Join FORNEC F On (F.CODIGO = RC.COD_FORNEC) ' +
    'Left Join TRANSPORTADORA T On (T.CODIGO = RC.TRANSP_CODIGO) ');
  InicializaDataSource;
end;

destructor TRequisicaoCompra.Destroy;
begin
  inherited;
end;

class function TRequisicaoCompra.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TRequisicaoCompra.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TRequisicaoCompra.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL + ' where ID = :pId');
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
  FEntidadeBase.SetReadOnly(Value, 'NOME', False);
  FEntidadeBase.SetReadOnly(Value, 'TRANSPORTADORA', False);
end;

function TRequisicaoCompra.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL + ' where 1 <> 1');
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TRequisicaoCompra.ModificaDisplayCampos;
begin

end;

function TRequisicaoCompra.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
