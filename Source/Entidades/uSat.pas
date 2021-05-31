unit uSat;

interface

uses
  Model.Entidade.Interfaces, Data.DB, uLib, System.SysUtils;

Type
  TSat = class(TInterfacedObject, iEntidade)
    private
      FEntidadeBase: iEntidadeBase<iEntidade>;
    public
      constructor Create;
      destructor Destroy; override;
      class function New: iEntidade;
      function EntidadeBase: iEntidadeBase<iEntidade>;
      function Consulta(Value: TDataSource): iEntidade;
      function InicializaDataSource(Value: TDataSource): iEntidade;

      procedure ModificaDisplayCampos;
  end;

implementation

uses
  uEntidadeBase;

{ TSat }

constructor TSat.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('Select SERIE as CODIGO, SERIE, MARCA, MODELO, null as INDICE From SAT_CADASTRO where STATUS = ''A'' ' +
                         'and COD_FILIAL = :CodFilial');
end;

destructor TSat.Destroy;
begin
  inherited;
end;

class function TSat.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TSat.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TSat.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  FEntidadeBase.Iquery.IndexFieldNames('SERIE');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);

  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TSat.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  FEntidadeBase.AddParametro('CodFilial', '1', ftString);
  FEntidadeBase.Iquery.IndexFieldNames('SERIE');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
end;

procedure TSat.ModificaDisplayCampos;
begin

end;

end.
