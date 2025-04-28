unit uEstoqueLocaisTrf;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils;
Type
  TEstoqueLocaisTrf = class(TInterfacedObject, iEntidade)
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

{ TEstoqueLocaisTrf }

constructor TEstoqueLocaisTrf.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('select ELT.* from ESTOQUE_LOCAIS_TRF ELT Where ELT.ID = :pId');
  InicializaDataSource;
end;

destructor TEstoqueLocaisTrf.Destroy;
begin
  inherited;
end;

class function TEstoqueLocaisTrf.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TEstoqueLocaisTrf.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TEstoqueLocaisTrf.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.IndexFieldNames('ID');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TEstoqueLocaisTrf.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.AddParametro('pId', '-1', ftString);
  FEntidadeBase.Iquery.IndexFieldNames('ID');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TEstoqueLocaisTrf.ModificaDisplayCampos;
begin

end;

function TEstoqueLocaisTrf.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
