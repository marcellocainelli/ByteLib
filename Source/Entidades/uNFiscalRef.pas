unit uNFiscalRef;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils, Byte.Lib;

Type
  TNiscalRef = class(TInterfacedObject, iEntidade)
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

{ TNiscalRef }

constructor TNiscalRef.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('select * from NFISCAL_DOCREFERENCIADO where NFNUMERO = :Parametro');
  InicializaDataSource;
end;

destructor TNiscalRef.Destroy;
begin
  inherited;
end;

class function TNiscalRef.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TNiscalRef.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TNiscalRef.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.AddParametro('Parametro', FEntidadeBase.TextoPesquisa, ftString);
  FEntidadeBase.Iquery.IndexFieldNames('ID');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TNiscalRef.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.IndexFieldNames('ID');
  FEntidadeBase.Iquery.SQL('select * from NFISCAL_DOCREFERENCIADO where (1 <> 1)');
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TNiscalRef.ModificaDisplayCampos;
begin

end;

function TNiscalRef.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;


end.
