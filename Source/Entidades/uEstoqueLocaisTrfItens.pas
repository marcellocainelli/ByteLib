unit uEstoqueLocaisTrfItens;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils;
Type
  TEstoqueLocaisTrfItens = class(TInterfacedObject, iEntidade)
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

{ TEstoqueLocaisTrfItens }

constructor TEstoqueLocaisTrfItens.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL(
    'select ELTI.*, P.NOME_PROD, P.FLG_GRADE ' +
    'from ESTOQUE_LOCAIS_TRF_ITENS ELTI ' +
    'Join PRODUTOS P on (P.COD_PROD = ELTI.COD_PROD) ' +
    'Where ID_ESTOQUE_LOCAL_TRF = :pId_Trf ');
  InicializaDataSource;
end;

destructor TEstoqueLocaisTrfItens.Destroy;
begin
  inherited;
end;

class function TEstoqueLocaisTrfItens.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TEstoqueLocaisTrfItens.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TEstoqueLocaisTrfItens.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.IndexFieldNames('ID');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
  FEntidadeBase.SetReadOnly(Value, 'nome_prod', False);
  FEntidadeBase.SetReadOnly(Value, 'flg_grade', False);
end;

function TEstoqueLocaisTrfItens.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.AddParametro('pId_Trf', '-1', ftString);
  FEntidadeBase.Iquery.IndexFieldNames('ID');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TEstoqueLocaisTrfItens.ModificaDisplayCampos;
begin

end;

function TEstoqueLocaisTrfItens.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
