unit uMDFe_Veiculo;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils;
Type
  TMDFe_Veiculo = class(TInterfacedObject, iEntidade)
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

{ TMDFe_Veiculo }

constructor TMDFe_Veiculo.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('Select * from MDFE_VEICULO');
  InicializaDataSource;
end;

destructor TMDFe_Veiculo.Destroy;
begin
  inherited;
end;

class function TMDFe_Veiculo.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TMDFe_Veiculo.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TMDFe_Veiculo.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL + ' where (1 <> 1)');
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TMDFe_Veiculo.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.IndexFieldNames('DESCRICAO');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TMDFe_Veiculo.ModificaDisplayCampos;
begin

end;

function TMDFe_Veiculo.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
