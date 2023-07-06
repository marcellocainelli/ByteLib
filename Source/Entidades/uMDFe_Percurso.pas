unit uMDFe_Percurso;

interface

uses
  Model.Entidade.Interfaces, Model.Conexao.Interfaces, Data.DB, System.SysUtils;

Type
  TMDFe_Percurso = class(TInterfacedObject, iEntidade)
    private
      FEntidadeBase: iEntidadeBase<iEntidade>;
    public
      constructor Create(AConn: iConexao = nil);
      destructor Destroy; override;
      class function New(AConn: iConexao = nil): iEntidade;
      function EntidadeBase: iEntidadeBase<iEntidade>;
      function Consulta(Value: TDataSource = nil): iEntidade;
      function InicializaDataSource(Value: TDataSource = nil): iEntidade;
      function DtSrc: TDataSource;
      procedure ModificaDisplayCampos;
  end;
implementation
uses
  uEntidadeBase;

{ TNfse }

constructor TMDFe_Percurso.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self, AConn);
  FEntidadeBase.TextoSQL('SELECT * FROM MDFE_PERCURSO Where 1=1 ');
  InicializaDataSource;
end;

destructor TMDFe_Percurso.Destroy;
begin
  inherited;
end;

class function TMDFe_Percurso.New(AConn: iConexao): iEntidade;
begin
  Result:= Self.Create(AConn);
end;

function TMDFe_Percurso.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TMDFe_Percurso.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  Case FEntidadeBase.TipoPesquisa of
    0: vTextoSQL:= FEntidadeBase.TextoSQL + ' and ID_MDFE = :mParametro';
  end;
  FEntidadeBase.AddParametro('mParametro', FEntidadeBase.TextoPesquisa, ftString);
  FEntidadeBase.Iquery.IndexFieldNames('ID');
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TMDFe_Percurso.InicializaDataSource(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSql:= 'Select * from MDFE_PERCURSO Where 1 <> 1';
  FEntidadeBase.Iquery.SQL(vTextoSql);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TMDFe_Percurso.ModificaDisplayCampos;
begin
  {$IFDEF MSWINDOWS}

  {$ENDIF}
end;

function TMDFe_Percurso.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
