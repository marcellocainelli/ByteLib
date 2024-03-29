unit uNfiscal_Intermediador;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils;

Type
  TNfiscal_Intermediador = class(TInterfacedObject, iEntidade)
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

{ TNFISCAL_INTERMEDIADOR }

constructor TNfiscal_Intermediador.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('Select * From NFISCAL_INTERMEDIADOR');

  InicializaDataSource;
end;

destructor TNfiscal_Intermediador.Destroy;
begin
  inherited;
end;

class function TNfiscal_Intermediador.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TNfiscal_Intermediador.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TNfiscal_Intermediador.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.IndexFieldNames('ID');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TNfiscal_Intermediador.InicializaDataSource(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;

  vTextoSql:= 'Select * From NFISCAL_INTERMEDIADOR Where 1 <> 1';
  FEntidadeBase.Iquery.SQL(vTextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TNfiscal_Intermediador.ModificaDisplayCampos;
begin

end;

function TNfiscal_Intermediador.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
