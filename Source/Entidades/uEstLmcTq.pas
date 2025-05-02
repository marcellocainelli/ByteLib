unit uEstLmcTq;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils, Dialogs;

Type
  TEstLmcTq = class(TInterfacedObject, iEntidade)
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
      procedure SelecionaSQLConsulta;
  end;
implementation
uses
  uEntidadeBase;

{ TEstLmcTq }

constructor TEstLmcTq.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  InicializaDataSource;
end;

destructor TEstLmcTq.Destroy;
begin
  inherited;
end;

class function TEstLmcTq.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TEstLmcTq.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TEstLmcTq.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  SelecionaSQLConsulta;
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
  ModificaDisplayCampos;
  Value.DataSet.Open;
end;

function TEstLmcTq.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  SelecionaSQLConsulta;
  FEntidadeBase.AddParametro('pSeq_Estoque', -1);
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TEstLmcTq.ModificaDisplayCampos;
begin
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('QUANTIDADE')).DisplayFormat:= '#,0.000';
end;

function TEstLmcTq.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

procedure TEstLmcTq.SelecionaSQLConsulta;
begin
  FEntidadeBase.TextoSQL('select * from ESTOQUE_LMC_TANQUE where SEQ_ESTOQUE = :pSeq_Estoque');
end;

end.
