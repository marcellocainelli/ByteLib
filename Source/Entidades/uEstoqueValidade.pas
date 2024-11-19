unit uEstoqueValidade;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils;

Type
  TEstoqueValidade = class(TInterfacedObject, iEntidade)
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

{ TBina }

constructor TEstoqueValidade.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL(
    'Select * ' +
    'from ESTOQUE_VALIDADES ' +
    'where (1 = 1) '
  );
  InicializaDataSource;
end;

destructor TEstoqueValidade.Destroy;
begin
  inherited;
end;

class function TEstoqueValidade.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TEstoqueValidade.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TEstoqueValidade.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.IndexFieldNames('DT_VALIDADE');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TEstoqueValidade.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL + ' and (1 <> 1)');
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TEstoqueValidade.ModificaDisplayCampos;
begin

end;

function TEstoqueValidade.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
