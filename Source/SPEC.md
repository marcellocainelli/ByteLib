# ByteLib — SPEC de Manutenção (ConexaoBD + Entidades)

> Gerado em 16/10/2026 por **leitura estática** do código em `E:\Prg_DelphiX\ByteLib\Source`. Nenhum arquivo-fonte foi alterado e **nada foi compilado ou executado**. Achados marcados como *(validar)* dependem de teste em runtime.
> Foco: `ConexaoBD\` (motor de conexão/queries) e `Entidades\` (219 units). `util\` é só mencionado onde consome o motor (já existe `util\CLAUDE.md` para ela).

---

## 1. Visão geral

ByteLib é uma biblioteca Delphi + FireDAC + Firebird que oferece:

1. **Motor de acesso (`ConexaoBD`)** — cria a conexão FireDAC lendo um `.ini`, e expõe queries, tabelas em memória e scripts por trás de **interfaces** (`iConexao`, `iQuery`, `iTable`, `iScript`), instanciadas via **fábricas** (`Controller.Factory.*`).
2. **Entidades (`Entidades`)** — uma classe por tabela/consulta (ex.: `TCliente` → `CADCLI`), todas implementando `iEntidade` e delegando o trabalho comum a `TEntidadeBase<T>`. Cada entidade monta o SQL de pesquisa, vincula parâmetros e entrega um `TDataSource` para a tela.

Estilo: *fluent interface* (métodos retornam a própria interface), gestão de memória por contagem de referência (`TInterfacedObject`), sem `.dpr/.dpk/.dproj` na pasta (os fontes entram no Library Path de quem consome).

### Estrutura de pastas

| Pasta | Conteúdo | Arquivos |
|---|---|---|
| `ConexaoBD\` | Motor: interfaces, fábricas, implementações FireDAC, DataModule global | 13 |
| `Entidades\` | 219 `.pas` (1 base genérica + 1 entidade genérica + 217 entidades de domínio) | 219 |
| `util\` | Integrações externas (TEF, WhatsApp, S3, frete…). Fora do foco; consome `iTable`/`TEntidade` | 24 |

---

## 2. Arquitetura

```
 Tela / Regra de negócio
        │  TCliente.New  (iEntidade)
        ▼
 Entidades\uCliente ──────────────► Model.Entidade.Interfaces
        │ TEntidadeBase<iEntidade>.New(Self)        (iEntidade, iEntidadeBase<T>, iEntidadeProduto)
        ▼
 Entidades\uEntidadeBase  (TEntidadeBase<T>)  ← texto/regra/tipo de pesquisa, DataSource, paginação, eventos
        │ TControllerFactoryQuery.New.Query(AConn)
        ▼
 ConexaoBD\Controller.Factory.*  ───────────► Model.Conexao.Interfaces (iConexao, iQuery, iTable, iScript)
        ▼
 ConexaoBD\Model.*.Firedac  (TModelQueryFiredac / TModelConexaoFiredac / TModelTableFiredac / TModelScriptFiredac)
        ▼
 FireDAC (TFDConnection, TFDQuery, TFDMemTable, TFDScript)  →  Firebird (FB)  |  SQLite (build APP)
```

Dependências importantes (acoplamentos que "vazam" a camada):

- `Model.Conexao.Firedac` usa `Byte.Lib` (de `util\`) e `Vcl.Forms/Vcl.Dialogs/Winapi.Windows`.
- `uEntidadeBase` usa `uDmConn` (DataModule global) além das fábricas.
- 21 entidades usam `Byte.Lib`; 4 (`uPagar`, `uProduto`, `uProduto_new`, `uProdutoCadastro`) usam `uDmFuncoes`, que **não está nesta pasta** (precisa estar no Library Path).
- `util\Byte.Controller.Nummus` e `util\PlugStorage.Service` consomem o motor (`TEntidade`, `iTable`).

---

## 3. ConexaoBD — catálogo de units

| Unit | Classe/Interface | Papel |
|---|---|---|
| `Model.Conexao.Interfaces` | `TipoConn`(=`FDConn`), `iConexao`, `iQuery`, `iTable`, `iScript` | Contratos do motor. Único ponto que as entidades "enxergam". |
| `Model.Entidade.Interfaces` | `iEntidadeBase<T>`, `iEntidade`, `iEntidadeProduto` | Contratos das entidades e da base genérica. |
| `Controller.Factory.Interfaces` | `iFactoryConn`, `iFactoryQuery`, `iFactoryTable` | Contratos das fábricas. |
| `Controller.Factory.Connection` | `TControllerFactoryConn` | *Builder* da conexão: `Database/Username/Password/Port/ForceBDConfig` → `Conn(FDConn)`. Defaults: `SYSDBA` / `masterkey`. |
| `Controller.Factory.Query` | `TControllerFactoryQuery` | `Query(Conn)` → `TModelQueryFiredac`. |
| `Controller.Factory.Table` | `TControllerFactoryTable` | `Table` → `TModelTableFiredac` (`TFDMemTable`). |
| `Model.Conexao.Firedac` | `TModelConexaoFiredac` | **Conexão** FireDAC: resolve parâmetros (INI), abre `TFDConnection`. Ver §4. |
| `Model.Query.Firedac` | `TModelQueryFiredac` | **Query** (`TFDQuery`, `CachedUpdates=True`, `ParamCreate=False`). Ver §5. |
| `Model.Table.Firedac` | `TModelTableFiredac` | Dataset em memória (`TFDMemTable`). |
| `Model.Script.Firedac` | `TModelScriptFiredac` | Executor de scripts (`TFDScript`) sobre a conexão. |
| `uDmConn` (+`.dfm`) | `TdmConn`, var global `dmConn` | DataModule que guarda **uma conexão compartilhada** (exceto `{$DEFINE SERVER}`). |
| `old_Model.Conexao.Firedac` | — | Versão antiga da conexão. **Declara `unit Model.Conexao.Firedac`** (mesmo nome da atual). Ver achado A-08. |

### 3.1 Defines de compilação usados

| Define | Efeito |
|---|---|
| `APP` | Conexão vira **SQLite** local (`bempresaapp.db`); entidades trocam SELECT/pesquisas por versões reduzidas (`{$IFDEF APP}`, 25 blocos). |
| `SERVER` | `dmConn.Connection` devolve `nil` e `dmConn` não é criado → **cada entidade abre sua própria conexão**. |
| `APPSERVER` | Em `ConnWindows`, lê `[HORSE_CONFIG] Database` do INI (servidor Horse). *(Relação exata com `SERVER`: confirmar com o time.)* |
| `BYTESUPER` | Usa `ByteSuper.Ini` e, com banco explícito, senha de `[SERVIDOR]`. |
| `MSWINDOWS` | Habilita units VCL e caminho `\bempresaapp.db`; em mobile usa `TPath.GetDocumentsPath`. |

---

## 4. Conexão "sob demanda" (`TModelConexaoFiredac`)

### 4.1 Como é obtida

```pascal
// 1) via DataModule global (padrão das entidades fora de SERVER)
dmConn.Connection               // iConexao único, criado no initialization de uDmConn

// 2) via fábrica (explícito)
Conn := TControllerFactoryConn.New
          .Database('host:C:\dados\banco.fdb')
          .Username('SYSDBA').Password('****').Port('3050')
          .ForceBDConfig(True)          // ignora o INI
          .Conn(FDConn);

// 3) direto
TModelConexaoFiredac.New;       // tudo vindo do INI
```

Ordem de resolução em `TEntidadeBase.Create`: `AConn` informado → `dmConn.Connection` (se não nil) → `TControllerFactoryConn.New.Conn(FDConn)` (nova conexão).

> "Sob demanda" aqui significa **conectar no momento em que o objeto é criado** (`FConexao.Connected := True` no construtor). Não há conexão preguiçosa (primeira query) nem reconexão automática.

### 4.2 Arquivo INI

Local: `ExtractFilePath(ParamStr(0))` — nome `ByteEmpresa.Ini` (ou `ByteSuper.Ini` com `BYTESUPER`).

| Seção | Chave | Uso |
|---|---|---|
| `[SISTEMA]` | `AcessoOnline` (bool) | Liga modo nuvem. |
| | `Database` | Caminho do banco (modo local). |
| | `DatabaseName` | Caminho do banco (modo online). |
| | `Server` | Host (aplicado só no modo online). |
| | `Port` | Porta (default `3050`). |
| | `Password` | Senha (modo online). |
| `[SISTEMA_OFFLINE]` | `BancoOffline` (bool), `Database` | Contingência: ignora o online. |
| `[HORSE_CONFIG]` | `Database` | Só `APPSERVER`. |
| `[SERVIDOR]` | `Password` | Só `BYTESUPER`, banco explícito, modo local. |

### 4.3 Regras de resolução (`ConnWindows`, linhas 117–182)

Com `ForceBDConfig = False`:

1. **Database vazio** → `APPSERVER`: `HORSE_CONFIG.Database`, senão `SISTEMA` (`DatabaseName` se online, `Database` se não). Demais builds: se `BancoOffline` → `SISTEMA_OFFLINE.Database` (e força offline); senão `DatabaseName`/`Database` conforme `AcessoOnline`.
2. **Database informado + online** → senha vem de `[SISTEMA] Password` e o modo online é **desligado** (não define `Server`).
3. **Database informado + local + `BYTESUPER`** → senha vem de `[SERVIDOR] Password`.

Com `ForceBDConfig = True`: nada de (1)–(3); usa só os argumentos (o INI ainda é lido para `Port` quando `FPort=''`).

Depois: `DriverName='FB'`, `Database/UserName/Password`, `Port` (argumento ou INI), e, se ainda online, `Server` + `Password` do INI.

### 4.4 Build `APP` (SQLite)

`BeforeConnect` troca para `DriverName='SQLITE'`, banco `bempresaapp.db` (Windows: pasta atual; mobile: Documentos, `OpenMode=CreateUTF8`).

---

## 5. Query (`TModelQueryFiredac`) — semântica real dos métodos

| Método | Comportamento (importante para quem mantém) |
|---|---|
| `SQL(Value)` | Fecha; se `Value` não vazio, **substitui** o SQL; **abre** (`Active:=True`). Sem `Value`, reabre o SQL atual. Serve só para SELECT. |
| `SQL_Add(txt, clear)` | Acrescenta ao SQL (opcionalmente limpando). **Não abre**; é usado com `SQL()` vazio no final (padrão "_new"). |
| `ExecQuery(txt)` | Fecha, **substitui** SQL e `ExecSQL` (DML/DDL). Sem controle de transação própria. |
| `AddParametro(nome, valor, tipo)` | Cria parâmetro manualmente (porque `ParamCreate=False`). Ver achado A-03. |
| `AddParametro(nome, int)` | Idem, inteiro. |
| `AddParametro(nome, valor, ftBlob, caminho)` / `(nome, ftBlob, stream)` | Carrega BLOB de arquivo/stream. Só `ftBlob`. |
| `Salva(Commit=True)` | `ApplyUpdates(0)` dentro de transação. **Dono da transação** (quando não há transação ativa): abre, aplica, commita e faz `CommitUpdates`. **Com transação externa ativa**: só aplica; não commita nem faz `CommitUpdates`. `Salva(False)` sem transação externa → exceção. |
| `ApplyUpdates` | Aplica + `CommitUpdates`, **sem** transação e sem checar erros. |
| `StartTransaction/Commit/Rollback/InTransaction` | Delegam à **conexão** (compartilhada). |
| `IndexFieldNames`, `CalcFields`, `InsertNewRecordEvent` | Configuram o `TFDQuery` (índice local, `OnCalcFields`, `OnNewRecord`). |
| `FetchOptions('Demand'/'All', rows)` | Strings *case-sensitive*; outro valor é ignorado. |
| `SetMode(x)` | **Ignora `x`**, sempre `fmAll` (A-09). |
| `ChangeCount(ds)`, `ClearDataset(ds)` | *Hard cast* para `TFDQuery`. |
| `GetFieldNames(tabela, lista)` | Metadados da conexão. |
| `SaveFileFromField(campo, caminho)` | Salva BLOB em arquivo. |
| `CaminhoBD`, `Password` | Expõem caminho e **senha** da conexão. |

Tradução de erros: `CatchApplyUpdatesErrors` percorre as linhas com erro e levanta a 1ª; `TrataErrosApplyUpdates` converte "violation of PRIMARY or UNIQUE KEY" em *"Código já cadastrado!"*.

### 5.1 Table e Script

- `TModelTableFiredac`: `CriaDataSet`, `CopiaDataSet` (`coStructure+coAppend`), `CloneCursor`, `EmptyDataset`, `IndexFieldNames`, `CriaCampo` (campo *internalcalc*), `FindField`.
- `TModelScriptFiredac`: `Add`, `SQLAdd` (usa `SQLScripts[0]`), `AddScriptsFromList`, `ValidateAll`, `ExecuteAll`, `Execute` (valida e executa), `Start/Commit/RollbackTransaction` via conexão. `BreakOnError=True`, `IgnoreError=False`.

---

## 6. Entidades

### 6.1 Contrato

Toda entidade implementa:

```pascal
iEntidade = interface
  function EntidadeBase: iEntidadeBase<iEntidade>;   // acesso à base (configuração/estado)
  function Consulta(Value: TDataSource = nil): iEntidade;              // monta SQL + abre + liga ao DataSource
  function InicializaDataSource(Value: TDataSource = nil): iEntidade;  // abre "vazio" para preparar grids/campos
  function DtSrc: TDataSource;
  procedure ModificaDisplayCampos;                   // máscaras, currency, DisplayFormat
end;
```

`TProduto`, `TProdutoCadastro`, `TPrecosItens` implementam `iEntidadeProduto` (acrescenta `ValidaDepto`, `CodDeptoUsuario`, `TipoConsulta`).

### 6.2 `TEntidadeBase<T>` (estado e utilitários)

| Grupo | Membros |
|---|---|
| Estado de pesquisa | `TextoSQL` (SQL base), `TextoPesquisa` (valor digitado), `TipoPesquisa` (int → *case* da entidade), `RegraPesquisa` (`Containing`/`Starting With`), `TipoConsulta` (`'Consulta'`, `'Filtra'`, `'Cadastro'`, `'PDV'`…), `Inativos` |
| Persistência | `Salva`, `Exclui`, `SaveIfChangeCount` |
| Parâmetros | 4 sobrecargas de `AddParametro` (delegam a `iQuery`) |
| Dataset/UI | `DataSource`, `Iquery`, `RefreshDataSource`, `ClearDataset`, `CriaCampo` (campos *internalcalc*), `SetReadOnly`, `Validate`, `CalcFields`, `InsertBeforePost/AfterPost/AfterEdit`, `InsertNewRecordEvent`, `FetchOptions` |
| Paginação | `Paginacao(pagina, linhas)` calcula a faixa; `Paginacao` anexa ` ROWS a TO b` ao SQL |
| Encadeamento | `&End` devolve o pai (referência **fraca**) |

Os setters `TextoSQL(v)`, `TextoPesquisa(v)`, `TipoPesquisa(v)`, `RegraPesquisa(v)`, `Inativos(v)`, `Pagina(v)`, `Pag_Rows(v)` **não são fluentes** (retornam `String/Integer/Boolean` descartável ou `procedure`); só `TipoConsulta(v)` retorna a interface.

### 6.3 Padrão de uma entidade

1. `Create`: `FEntidadeBase := TEntidadeBase<iEntidade>.New(Self)`; define `TextoSQL` (SELECT base terminando em `Where (1=1) and ` ou `Where 1 <> 1`); chama `InicializaDataSource` (**executa uma query**) e, se aplicável, `InsertNewRecordEvent(OnNewRecord)`.
2. `Consulta`: escolhe o filtro por `TipoPesquisa` (*case*), concatena ao `TextoSQL`, faz `AddParametro('Parametro'|'pXxx'|'mXxx', TextoPesquisa, ftString)`, `Iquery.IndexFieldNames(...)`, `Iquery.SQL(sql)`, `ModificaDisplayCampos`, `Value.DataSet := Iquery.Dataset`.
3. `InicializaDataSource`: abre o mesmo SELECT com parâmetro "-1"/`1<>1` para ter metadados/campos sem trazer linhas.
4. Gravação: a tela edita o `DataSet` (CachedUpdates) e chama `EntidadeBase.Salva` / `Exclui`.

Convenção de nome de parâmetro (ocorrências em `AddParametro`): `pXxx` (65), `Parametro` (34), `mXxx` (22). Parâmetros típicos: `:Parametro`/`:pParametro`/`:mParametro` (valor da busca), `:mCodFilial`, `:pFilial`, `:mCOD_MARCA`…

### 6.4 Template para nova entidade

Copiar uma entidade simples (ex.: `uBanco.pas`, `uCfop.pas`) e ajustar:

```pascal
constructor TXxx.Create;
begin
  FEntidadeBase := TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('Select <colunas> From <TABELA> Where (1=1) and ');
  InicializaDataSource;
end;
// Consulta: case FEntidadeBase.TipoPesquisa of 0: ... + 'CODIGO = :Parametro'; ...
// SEMPRE parametrizar o valor (nunca concatenar TextoPesquisa).
```

Para SQL ad-hoc sem classe própria existe `TEntidade` (`uEntidade.pas`): `TEntidade.New(AConn).EntidadeBase.TextoSQL(sql)` → `Consulta` (usada por `util\`).

### 6.5 Catálogo por domínio (resumo; lista completa no **Apêndice A**)

| Domínio | Units (prefixo) |
|---|---|
| Clientes | `uCliente*` (Carro, Contato, Dependentes, Email, Entrega, Fone, Pacotes), `uCashback`, `uHaver`, `uConsumidor`, `uConvenio*` |
| Produtos / Estoque | `uProduto*`, `uEstoque*`, `uLote`, `uGrupo`, `uSubgrupo`, `uMarca`, `uColecao`, `uTamanho`, `uGrade_Variacoes*`, `uPrecos*`, `uTelaPreco*`, `uPromocao*`, `uProducao*` |
| Vendas / Orçamento / Pedido | `uOrcamento*`, `uPedido*`, `uItensPedido`, `uVendaItens`, `uVendaAdicionais`, `uEmpenho*`, `uRequisicaoCompra*`, `uEntrega`, `uSat*` |
| Financeiro | `uPagar*`, `uReceber*`, `uRecebido`, `uBanco`, `uConta`, `uCaixa`, `uFechaCaixa`, `uCartao`, `uAdmCartao`, `uOperadora`, `uPix_*`, `uPredatado`, `uCadbanCobranca`, `uCondicao*` |
| Fiscal | `uNfe*`, `uNFSe*`, `uNfiscal_*`, `uMDFe*`, `uCfop`, `uCst`, `uIcms*`, `uNcm*`, `uCest`, `uIbsCbs_cClassTrib` |
| Ordem de Serviço | `uOrd*`, `uOrdem*` (Ótica, Joalheria, Equipamentos, Garantia…) |
| Posto de combustível | `uPosto_*`, `uCombustivel`, `uEstLmcTq` |
| Pet | `uPet*` |
| Configuração / Cadastros | `uConfig*`, `uFilial*`, `uFunci`, `uUsuario`, `uAcessoMenu`, `uPreferencias`, `uPais`, `uEstado`, `uMunicipio`, `uTransportadora`, `uFornec`… |

---

## 7. Achados — falhas e riscos (priorizados)

Legenda: **Alta** = risco de dados/segurança/concorrência; **Média** = bug funcional ou manutenção difícil; **Baixa** = higiene. "Confirmado" = visível no código; *(validar)* = depende de execução.

### Alta

| ID | Onde | Problema | Sugestão |
|---|---|---|---|
| **A-01** | `Model.Conexao.Firedac` l.46–47, 87–95 | Credenciais/banco ficam em **`class var`** (`FDatabase/FUsername/FPassword/FPort/FForceBDConfig`) gravadas em `New` e lidas em `Create`; `ConnWindows` ainda **sobrescreve** `FDatabase/FPassword`. Em servidor multi-thread (Horse/`APPSERVER`) duas requisições simultâneas podem misturar banco/usuário/senha. *Confirmado.* | Tornar campos de **instância** e passar parâmetros ao construtor (`Create(ADatabase,…)`). |
| **A-02** | `uDmConn`, `uEntidadeBase.Create` | Fora de `SERVER`: **uma conexão global** compartilhada por todas as entidades/telas (transações misturadas, ver A-05). Em `SERVER`: `dmConn.Connection = nil` → **cada entidade cria uma `TFDConnection` nova** (e `Connected := True` + query do `InicializaDataSource`). Sem `Pooled`, sem `ConnectionDefName`. *Confirmado.* | Registrar uma *ConnectionDef* com `Pooled=True` (FireDAC pool) e um provedor de conexão por requisição/thread; reutilizar `iConexao` dentro da requisição. |
| **A-03** | `Model.Query.Firedac` l.139–148, 165–172 | `AddParametro` chama `Params.Add` **várias vezes por chamada** (nome, tipo, tamanho, `ParamType` em itens diferentes): cria 3–4 parâmetros, só o 1º tem nome/valor; `DataType/Size/ParamType` são aplicados a parâmetros "fantasma". O tipo real é inferido do `Variant`. `Size := Length(NomeParametro)` usa o tamanho do **nome** (deveria ser do valor). Parâmetros nunca são limpos entre `Consulta`s → duplicatas por nome. *Confirmado no código; efeito em runtime (validar).* | Criar **um** `TFDParam` (`ParamByName`/`Params.Add` uma vez), setar `DataType/ParamType/Value` nele; `Params.Clear` ao trocar o SQL (ou ao final de `SQL`/`ExecQuery`). |
| **A-04** | `uCliente.pas` l.116; `uCliente_new.pas` l.108; `uPagar.pas` l.78; `uPredatado.pas` l.86; `uProduto.pas` l.267 | **SQL Injection** por concatenação de `TextoPesquisa` (lista `IN (...)`, nome de coluna, filtro NCM via `DmFuncoes.GeraFiltroBucaProdutos_NCM`). `RegraPesquisa` (operador) também é concatenado. *Confirmado.* | Validar com `TryStrToInt` por item/`TRegEx`, usar lista de colunas permitidas (`case`), operador via *whitelist* (`Containing`/`Starting With`). |
| **A-05** | `Salva`/`Exclui` (l.212–241 / `uEntidadeBase` l.93–120) | (a) Com transação externa ativa, `Salva(True)` **nunca commita** e **não chama `CommitUpdates`** → o chamador precisa commitar e limpar o cache, senão o próximo `Salva` reaplica as mesmas linhas *(validar)*. (b) `Exclui` faz `Delete` e, se `Salva` falhar, a linha continua "deletada" no cache (falta `CancelUpdates`). (c) Rollback externo não cancela o cache. (d) Como a conexão é compartilhada (A-02), "estar em transação" pode ser de **outra** tela. | Documentar/impor o contrato: `Salva` sempre `ApplyUpdates`; chamador faz `Commit` + `CommitUpdates` (ou `Rollback` + `CancelUpdates`). Usar `TFDTransaction` própria por unidade de trabalho. |
| **A-06** | `Controller.Factory.Connection`, `Model.Conexao.Firedac`, `iQuery.Password` | Credenciais **padrão `SYSDBA/masterkey` no código**; senha em INI texto-plano; `iQuery.Password` expõe a senha pela interface. *Confirmado.* | Remover defaults; ler de cofre/variável de ambiente/INI cifrado; excluir `Password` de `iQuery`. |

### Média

| ID | Onde | Problema | Sugestão |
|---|---|---|---|
| **A-07** | `Controller.Factory.Interfaces` | `iFactoryQuery` e `iFactoryTable` têm o **mesmo GUID** (`{40B5AF12-7E1D-48E8-A676-E3E96380D872}`) → `Supports/QueryInterface/as` ambíguo. *Confirmado.* | Gerar GUID novo para uma delas. |
| **A-08** | `ConexaoBD\old_Model.Conexao.Firedac.pas` | O arquivo "old" declara `unit Model.Conexao.Firedac` (igual à atual): se entrar no projeto/Library Path, o compilador usa um ou outro conforme a ordem (erro F2051/versão errada). *Confirmado.* | Mover para fora do Source (ou ao controle de versão) / renomear a unit. |
| **A-09** | `SetMode` (l.270–274) | Ignora `pModo`; sempre `fmAll`. *Confirmado.* | Respeitar o parâmetro (ou remover o método). |
| **A-10** | `Model.Table.Firedac.CriaCampo` l.92–98; `uEntidadeBase.CriaCampo` l.196–205, 219–228 | `vField` fica **não inicializado** para tipos fora do `case` (ex.: `ftInteger/ftString/ftFloat` na Table; `ftDate/ftDateTime/ftLargeint…` na Base) → violação de acesso. Também fecha o dataset e recria todos os campos a cada chamada. *Confirmado.* | Adicionar `else raise`/mais tipos; criar campos via `FieldDefs.Add` + `CreateDataSet`. |
| **A-11** | `Model.Conexao.Firedac.ErroConnection`, `FDConnLostConnection` | `ExitProcess(0)` + `MessageBox/ShowMessage` dentro da camada de dados; handlers de perda de conexão estão **desligados** (comentados) → código morto; `ErroConnection` sempre lê `ByteEmpresa.Ini` (ignora `BYTESUPER`) e não libera `vArqIni`. Unit arrasta `Vcl.Forms/Dialogs/Winapi` (inutiliza reuso em serviço/console). Também importa **`FireDAC.FMXUI.Wait` e `FireDAC.VCLUI.Wait` juntas**. *Confirmado.* | Levantar exceção/evento (`OnLost`) e deixar a UI decidir; separar em unit `UI`; manter só uma unit de *wait cursor* por plataforma. |
| **A-12** | `TModelConexaoFiredac.Create` | Não define `LoginPrompt := False`, `CharacterSet`, `Protocol`, timeouts (`ConnectionTimeout/CommandTimeout`), nem `AutoReconnect`. O *charset* depende do default do driver *(validar acentuação por banco)*. Falha de rede levanta exceção direto no construtor da entidade. | Parametrizar via INI: `CharacterSet`, `Protocol=TCPIP`, `LoginPrompt=False`, `ResourceOptions.AutoReconnect`, timeouts. |
| **A-13** | `TModelScriptFiredac` | `SQLAdd/SQLSaveToFile` usam `SQLScripts[0]` sem garantir `Add` antes (`EListError`); `Execute` re-lança `Exception.Create(E.Message)` (perde classe/`ErrorCode`); `Create(nil)` cria uma conexão extra; `ExecuteAll` não valida. | Garantir script 0 na criação; `raise;` preservando exceção. |
| **A-14** | `CatchApplyUpdatesErrors` / `TrataErrosApplyUpdates` | Navega o dataset (`First/Next`) sem `DisableControls` nem restaurar posição (grid "pula", dispara `AfterScroll`); reporta só o 1º erro; compara **texto em inglês** da mensagem; qualquer violação de PK/UNIQUE vira "Código já cadastrado!". | Usar `EFDDBEngineException.Kind`/`ErrorCode` (`ekUKViolated`, `ekFKViolated`); `Bookmark` + `DisableControls`. |
| **A-15** | Todas as entidades (213 de 219) | `InicializaDataSource` é chamada **no construtor** → cada `New` abre conexão (em `SERVER`) e executa uma query. Impacta tempo de abertura de telas/endpoints. | Inicialização preguiçosa (na 1ª `Consulta`/uso do `DtSrc`). |
| **A-16** | `uCliente_new`/`uProduto_new` (versão `APP`) | Mistura de estilos: `SQL_Add` já carregou o SQL, mas o ramo `APP` ainda usa `vTextoSQL` e termina com `SQL(vTextoSQL)`, **sobrescrevendo** `Inativos` e `Paginacao`. Em `uCliente.pas` (APP, caso 0) `... Order By 2` + `' and OBS <> ''INT'' Order By 2'` gera **SQL inválido** quando `Inativos`. *Confirmado.* | Padronizar um único estilo (`SQL_Add`) e mover `Order By` para o final. |
| **A-17** | `Salva` (`uEntidadeBase` l.99–104) | No `except` chama `Value.DataSet.Edit` — pode levantar nova exceção (dataset vazio/fechado) e **mascarar** o erro original; a mensagem final perde a classe/código da exceção original. | `try`/`except` interno; reempacotar preservando `InnerException`. |
| **A-18** | `Salva(Value, …)`, `SaveIfChangeCount(Value)` | `Value` só é usado para `Edit` em erro e para contar mudanças; **`FQuery.Salva` grava sempre o `TFDQuery` interno**, nunca `Value`. API enganosa se `Value` ≠ dataset da base. | Aplicar `ApplyUpdates` no dataset de `Value` ou remover o parâmetro. |

### Baixa

| ID | Onde | Problema |
|---|---|---|
| **A-19** | `Paginacao` | `ROWS a TO b` precisa ir após o `ORDER BY`; sem `ORDER BY` a página é não determinística. `Paginacao(p, n)` com `p<=0` mantém valores antigos. Só `uCliente_new`/`uProduto_new` usam. |
| **A-20** | Classes duplicadas | `TCliente` em `uCliente` **e** `uCliente_new`; `TProduto` em `uProduto` **e** `uProduto_new` (mesmo nome de classe → ambiguidade por ordem de `uses`). `uConfigImagens.pas` declara **`TAcessoMenu`** (copy/paste de `uAcessoMenu`). `uNFiscalRef` → classe `TNiscalRef` (typo). |
| **A-21** | Tabelas repetidas | Mesma tabela em units diferentes: `ESTOQUEFILIAL_LOTE` (`uLote`/`uProdutoLote`), `PRODUTOS_TAMANHO` (`uTamanho`/`uProdutoTamanho`), `RECEBER` (`uReceber`/`uReceber_Boleto`), `ORD_STATUS` (`uOrdStatus`/`uOrdemStatus`), `ORC_PEND` (`uOrcamento`/`uPedido`), `PEDIDO` (`uOrcamentoItens`/`uItensPedido`). Pode ser intencional (visões diferentes) — documentar. |
| **A-22** | `SaveFileFromField`, `AddParametro` BLOB | Teste `FieldByName = nil` é inútil (levanta exceção); usa `TStringStream` para binário (preferir `TBytesStream/TMemoryStream`); `AddParametro` BLOB **ignora em silêncio** `FilePath` vazio ou tipo ≠ `ftBlob` (e `ftMemo/ftGraphic`). |
| **A-23** | *Hard casts* | `TFDQuery(DataSet)` em `ChangeCount/ClearDataset`; `TFDDataSet(DataSet)` em `CloneCursor`; `TFDConnection(FParent.Connection)` em todo lugar. Trocar por `as` ou guarda de tipo. |
| **A-24** | `Controller.Factory.Connection.Conn` | `case` sem `else`: novo `TipoConn` deixaria `Result` indefinido. |
| **A-25** | `TEntidadeBase` | `FParent` é `[Weak]`: `TCliente.New.EntidadeBase....&End` devolve `nil` se a entidade não for mantida em variável. `Destroy` chama `inherited` antes de liberar `FDataSource` (funciona, mas fora do padrão). |
| **A-26** | SQL | `Select *`/`P.*`/`c.*` em ~125 entidades (tráfego e fragilidade a mudança de schema); `Order By <nº>` posicional em 8; `ModificaDisplayCampos` usa `FieldByName` (quebra se o campo sair do SELECT — por isso o `{$IFNDEF APP}`). Funções Firebird (`CONTAINING`, `STARTING WITH`, `ROWS`, `spApenasNumeros`) nos mesmos fontes do build `APP`/SQLite *(validar compatibilidade)*. |
| **A-27** | Encoding | 216 arquivos em **ANSI (Windows-1252)** e 3 em **UTF-8 com BOM** (`uEntidadeBase`, `uProduto`, `uProduto_new`). Literais acentuados (`'Início do texto'`) dependem disso. Risco ao editar/versionar em ferramentas UTF-8. |
| **A-28** | `Model.Conexao.Firedac` | `uses Byte.Lib` sem uso aparente; campo `FUpdateTransaction` e blocos "ALTERACOES PARA TESTE" comentados; `TModelQueryFiredac.FScript` nunca é criado (só liberado). Datas passadas como string `mm/dd/yyyy` em `ftString` (`uCliente` caso 10) — preferir `ftDate`. |

---

## 8. Melhorias recomendadas (roadmap sugerido)

**Curto prazo (baixo risco, alto retorno)**
1. Corrigir `AddParametro` (A-03) e limpar `Params` por consulta — maior ganho de correção.
2. Fechar os 5 pontos de SQL injection (A-04).
3. GUID duplicado (A-07) e `old_Model.Conexao.Firedac` fora do caminho (A-08).
4. `LoginPrompt=False`, `CharacterSet` explícito e remoção de defaults de credencial (A-06, A-12).

**Médio prazo**
5. Conexão por requisição + **pool FireDAC** e remoção de `class var` (A-01, A-02).
6. Contrato de transação claro (`Salva`/`Exclui`/`CancelUpdates`/`CommitUpdates`) e transação própria (`TFDTransaction`) (A-05, A-17, A-18).
7. Separar UI (`MessageBox`, `ExitProcess`) da camada de conexão; tratar perda de conexão por evento (A-11).
8. Inicialização preguiçosa das entidades (A-15).
9. Tradução de erros por `ErrorCode` (A-14).

**Longo prazo**
10. Consolidar `uCliente/_new` e `uProduto/_new` em um estilo só (`SQL_Add` + `Paginacao`) e aplicar o mesmo padrão às demais.
11. Substituir `Select *` por colunas explícitas; remover `Order By` posicional.
12. Testes automatizados (DUnitX) para `TModelQueryFiredac` (parâmetros, transação, `Salva`) com banco Firebird de teste.
13. Padronizar encoding (UTF-8 com BOM) e adicionar `.dproj/.groupproj`/`.editorconfig` ao repositório.

---

## 9. Guia rápido de armadilhas (para quem vai dar manutenção)

- **Mantenha a entidade em variável**: `var Cli: iEntidade := TCliente.New;` — não encadeie só `.EntidadeBase` (o pai é referência fraca).
- **Sempre `AddParametro` antes de `Consulta`/`SQL`**: com `ParamCreate=False`, parâmetro `:x` não declarado causa erro na abertura.
- **`SQL()` abre o dataset**; para DML use `ExecQuery`. Para montar SQL em partes use `SQL_Add` e finalize com `SQL` vazio.
- **`CachedUpdates` está sempre ligado**: editar o dataset não grava nada até `Salva`. Esquecer `Salva` = perda silenciosa.
- **Transações**: se você abriu uma transação, `Salva` não commita — faça `Commit` e depois `Iquery.CommitUpdates` (ou `Rollback` e cancele o cache).
- **Build `SERVER`**: nenhuma conexão compartilhada; passe `AConn` à entidade (`TEntidade.New(AConn)` / `TEntidadeBase.New(Self, AConn)`) para reutilizar a conexão da requisição.
- **Setters da base não são fluentes** (`TextoPesquisa(x)`, `TipoPesquisa(x)`…): chame em linhas separadas.
- **`TipoPesquisa` é o índice do `case`** da entidade — ao inserir um caso, não renumere os existentes (as telas usam o número).
- **`RegraPesquisa`**: telas enviam `'Contendo'`/`'Início do texto'`; a entidade converte para `'Containing'`/`'Starting With'` (literais acentuados — atenção ao encoding).
- **Paginação**: chamar `Paginacao` **depois** de todo `ORDER BY`.

---

## 10. Pontos em aberto (confirmar com o time)

1. Significado exato dos defines `SERVER` × `APPSERVER` e qual build é usado em produção multi-thread.
2. Qual das duas versões (`uCliente` × `uCliente_new`, `uProduto` × `uProduto_new`) está em uso; a "_new" migra o ramo não-`APP` para `SQL_Add` + `Paginacao`, mas deixa o ramo `APP` no estilo antigo (ver A-16).
3. Se o build `APP` (SQLite) realmente executa as pesquisas com `CONTAINING/STARTING WITH` (sintaxe Firebird).
4. Charset dos bancos em produção (WIN1252 × UTF8) e se há `Pooled` configurado fora destes fontes.
5. Origem de `uDmFuncoes` e `Controller.LogError` (fora desta pasta).

---

## Apêndice A — Catálogo completo de entidades

Colunas: **Unit** · **Classe** · **Interface** · **Tabela principal** (1ª tabela do `FROM`) · **Casos de pesquisa** (`TipoPesquisa`, contagem aproximada) · **Linhas** · **Particularidades** (`NewRec` = `OnNewRecord`; `Calc` = `OnCalcFields`; `APP` = ramo `{$IFDEF APP}`; `GetText` = formatação de campo).

| Unit | Classe | Interface | Tabela | Casos | Linhas | Particularidades |
|---|---|---|---|---|---|---|
| uAcessoMenu.pas | TAcessoMenu | iEntidade | DIREITOSUSUARIO | — | 86 | — |
| uAdicionais.pas | TAdicionais | iEntidade | PRODUTOS_ADICIONAIS | 2 | 102 | — |
| uAdmCartao.pas | TAdmCartao | iEntidade | CARTAO_ADMINISTRADORA | — | 87 | — |
| uAgenda.pas | TAgenda | iEntidade | AGENDA | 3 | 96 | — |
| uAgendaGruposUsuarios.pas | TAgendaGruposUsuarios | iEntidade | AGENDA_GRUPOS_USUARIOS | — | 87 | — |
| uAgendaServico.pas | TAgendaServico | iEntidade | AGENDASERVICO | 1 | 104 | — |
| uAgenda_Grupos.pas | TAgenda_Grupos | iEntidade | AGENDA_GRUPOS | — | 84 | — |
| uBalancaSetor.pas | TBalancaSetor | iEntidade | BALANCA_SETOR | — | 84 | — |
| uBanco.pas | TBanco | iEntidade | BANCO | 3 | 92 | — |
| uBina.pas | TBina | iEntidade | BINA | — | 85 | — |
| uBrindes.pas | TBrindes | iEntidade | BRINDES | 2 | 91 | — |
| uBrindesResgate.pas | TBrindesResgate | iEntidade | BRINDES_RESGATE | — | 84 | — |
| uCadbanCobranca.pas | TCadbanCobranca | iEntidade | CADBAN_COBRANCA | — | 83 | — |
| uCaixa.pas | TCaixa | iEntidade | CAIXA | 1 | 92 | NewRec, APP |
| uCartao.pas | TCartao | iEntidade | CARTAO | 1 | 111 | NewRec |
| uCashback.pas | TCashback | iEntidade | CADCLI_CASHBACKS | 4 | 82 | — |
| uCategoria.pas | TCategoria | iEntidade | CATEGORIAS | — | 83 | — |
| uCentroCusto.pas | TCentroCusto | iEntidade | CENTROCUSTO | — | 82 | — |
| uCest.pas | TCest | iEntidade | TAB_CEST | 2 | 91 | — |
| uCfop.pas | TCfop | iEntidade | CFOP | — | 84 | — |
| uCliente.pas | TCliente | iEntidade | CADCLI | 20 | 173 | NewRec, APP |
| uClienteCarro.pas | TClienteCarro | iEntidade | CARRO | 1 | 91 | — |
| uClienteContato.pas | TClienteContato | iEntidade | CADCLI_HIST_CONTATOS | — | 86 | — |
| uClienteDependentes.pas | TClienteDependentes | iEntidade | CADCLI_DEPENDENTES | — | 87 | — |
| uClienteEmail.pas | TClienteEmail | iEntidade | CADCLI_EMAIL | — | 84 | — |
| uClienteEntrega.pas | TClienteEntrega | iEntidade | CADCLI_LOCALENTREGA | — | 84 | — |
| uClienteFone.pas | TClienteFone | iEntidade | CADCLI_FONES | — | 84 | — |
| uClientePacotes.pas | TClientePacotes | iEntidade | CADCLI_PACOTES | — | 82 | — |
| uCliente_new.pas | TCliente | iEntidade | CADCLI | 20 | 168 | NewRec, APP |
| uColecao.pas | TColecao | iEntidade | COLECAO | — | 82 | — |
| uCombustivel.pas | TCombustivel | iEntidade | PRODUTOS | — | 90 | — |
| uComposicaoOrcamento.pas | TComposicaoOrcamento | iEntidade | PEDIDO_COMPOSICAO | — | 92 | — |
| uCondicaoPagamento.pas | TCondicaoPagamento | iEntidade | CONDPGTO | 2 | 90 | — |
| uCondicaoVenda.pas | TCondicaoVenda | iEntidade | CONDICAO_VENDA | — | 94 | — |
| uCondicaoVendaParcelas.pas | TCondicaoVendaParcelas | iEntidade | CONDICAO_VENDA_PARCELAS | — | 86 | — |
| uConfig.pas | TConfig | iEntidade | CONFIG | — | 82 | — |
| uConfigCaixa.pas | TConfigCaixa | iEntidade | CONFIG_CAIXA | — | 83 | — |
| uConfigCashback.pas | TConfigCashback | iEntidade | CONFIG_CASHBACK | — | 75 | — |
| uConfigEstoque.pas | TConfigEstoque | iEntidade | CONFIG_ESTOQUE | — | 82 | — |
| uConfigFPgto.pas | TConfigFPagto | iEntidade | CONFIG_FORMAPAGAMENTO | 1 | 87 | — |
| uConfigFinanceiro.pas | TConfigFinanceiro | iEntidade | CONFIG_FINANCEIRO | — | 85 | — |
| uConfigImagens.pas | TAcessoMenu | iEntidade | CONFIG_IMAGENS | — | 80 | — |
| uConfigOS.pas | TConfigOS | iEntidade | CONFIG_ORDEMSERVICO | — | 77 | — |
| uConfig_DoutorByte.pas | TConfig_DoutorByte | iEntidade | CONFIG_DOUTORBYTE | — | 88 | — |
| uConsumidor.pas | TConsumidor | iEntidade | CONSUMIDOR | 2 | 89 | — |
| uConta.pas | TConta | iEntidade | CADBAN | 2 | 108 | — |
| uContabilista.pas | TContabilista | iEntidade | CONTABILISTA | — | 86 | — |
| uConvenio.pas | TConvenio | iEntidade | CONVENIO | — | 86 | — |
| uConvenio_Descontos.pas | TConvenio_Descontos | iEntidade | CONVENIO_DESCONTOS | — | 89 | — |
| uCst.pas | TCst | iEntidade | CST | — | 85 | — |
| uDevolucaoReferenciado.pas | TDevolucaoReferenciado | iEntidade | DEVOLUCAO_DOCREFERENCIADO | 1 | 112 | NewRec |
| uEmpenho.pas | TEmpenho | iEntidade | PENDENCIA | 1 | 118 | NewRec, Calc, GetText |
| uEmpenho_Entrega.pas | TEmpenho_Entrega | iEntidade | PENDENCIA_ENTREGA | 1 | 120 | NewRec, Calc, GetText |
| uEmpenho_Entrega_Itens.pas | TEmpenhoEntrega_Itens | iEntidade | PENDENCIA_ENTREGA_ITENS | 1 | 121 | NewRec, Calc, GetText |
| uEmpenho_Itens.pas | TEmpenho_Itens | iEntidade | ITENSPENDENCIA | 1 | 125 | NewRec, Calc, GetText |
| uEntidade.pas | TEntidade | iEntidade | — | — | 81 | — |
| uEntradaEstoqueItens.pas | TEntradaEstoqueItens | iEntidade | ESTOQUE | 1 | 92 | — |
| uEntrega.pas | TEntrega | iEntidade | ENTREGA | — | 79 | — |
| uEquipamentosLocacaoAvulso.pas | TEquipamentosLocacaoAvulso | iEntidade | LOCACAO_EQUIPAMENTOS | 4 | 85 | — |
| uEstFilialGradeEntrada.pas | TEstFilialGradeEntrada | iEntidade | ESTFILIAL_GRADE_ENTRADA | — | 94 | — |
| uEstLmcTq.pas | TEstLmcTq | iEntidade | ESTOQUE_LMC_TANQUE | — | 88 | — |
| uEstado.pas | TEstado | iEntidade | ESTADOS | — | 85 | — |
| uEstoque.pas | TEstoque | iEntidade | ESTOQUE | 1 | 135 | NewRec, APP, GetText |
| uEstoqueColetor.pas | TEstoqueColetor | iEntidade | ESTOQUE_COLETOR | 4 | 102 | — |
| uEstoqueFilial.pas | TEstoqueFilial | iEntidade | ESTOQUEFILIAL | — | 90 | — |
| uEstoqueFilialGrade.pas | TEstoqueFilialGrade | iEntidade | ESTOQUEFILIAL_GRADE | — | 90 | — |
| uEstoqueLocaisGrades.pas | TEstoqueLocaisGrades | iEntidade | ESTOQUE_LOCAIS_GRADES | — | 88 | — |
| uEstoqueLocaisTrf.pas | TEstoqueLocaisTrf | iEntidade | ESTOQUE_LOCAIS_TRF | — | 82 | — |
| uEstoqueLocaisTrfGrades.pas | TEstoqueLocaisTrfGrades | iEntidade | ESTOQUE_LOCAIS_TRF_GRADES | — | 88 | — |
| uEstoqueLocaisTrfItens.pas | TEstoqueLocaisTrfItens | iEntidade | ESTOQUE_LOCAIS_TRF_ITENS | — | 88 | — |
| uEstoqueLocal.pas | TEstoqueLocal | iEntidade | ESTOQUE_LOCAIS | — | 91 | — |
| uEstoqueMestre.pas | TEstoqueMestre | iEntidade | ESTOQUEMESTRE | 1 | 128 | NewRec, Calc, APP, GetText |
| uEstoqueTransportadora.pas | TEstoqueTransportadora | iEntidade | ESTOQUE_TRANSPORTADORA | 1 | 120 | NewRec, Calc, GetText |
| uEstoqueValidade.pas | TEstoqueValidade | iEntidade | ESTOQUE_VALIDADES | — | 85 | — |
| uEstoque_Fracionamento.pas | TEstoque_Fracionamento | iEntidade | ESTOQUE_FRACIONAMENTO | 1 | 117 | NewRec, Calc, APP, GetText |
| uEtiquetasFast.pas | TEtiquetasFast | iEntidade | ETIQUETAS_FAST | — | 85 | — |
| uFechaCaixa.pas | TFechaCaixa | iEntidade | FECHACAIXA | 2 | 91 | — |
| uFilial.pas | TFilial | iEntidade | FILIAL | 1 | 106 | APP |
| uFilial_Email.pas | TFilial_Email | iEntidade | FILIAL_EMAIL | — | 84 | — |
| uFornec.pas | TFornec | iEntidade | FORNEC | 9 | 120 | — |
| uFunci.pas | TFunci | iEntidade | FUNCI | 1 | 98 | — |
| uGrade_Variacoes.pas | TGrade_Variacoes | iEntidade | GRADE_VARIACOES | — | 83 | — |
| uGrade_Variacoes_Itens.pas | TGrade_Variacoes_Itens | iEntidade | GRADE_VARIACOES_ITENS | — | 88 | — |
| uGrupo.pas | TGrupo | iEntidade | MARCAS | — | 97 | — |
| uGrupoPromocao.pas | TGrupoPromocao | iEntidade | GRUPO_PROMOCAO | 2 | 85 | — |
| uGrupoPromocao_Itens.pas | TGrupoPromocaoItem | iEntidade | GRUPO_PROMOCAO_ITEM | 6 | 99 | — |
| uGruposAdicionais.pas | TGruposAdicionais | iEntidade | GRUPOS_ADICIONAIS | 1 | 76 | — |
| uHaver.pas | THaver | iEntidade | HAVER | 2 | 92 | NewRec |
| uIbsCbs_cClassTrib.pas | TIbsCbs_cClassTrib | iEntidade | IBSCBS_CLASSTRIB | 2 | 94 | — |
| uIcms.pas | TIcms | iEntidade | ICMS | — | 85 | — |
| uIcmsPartilha.pas | TIcmsPartilha | iEntidade | ICMS_PARTILHA | — | 82 | — |
| uImovel.pas | TImovel | iEntidade | IMOVEL | — | 83 | — |
| uItensPedido.pas | TItensPedido | iEntidade | PEDIDO | — | 86 | — |
| uLocacaoEquipAvulso.pas | TLocacaoEquipAvulso | iEntidade | LOCACAO_EQUIP_AVULSO | 6 | 92 | — |
| uLote.pas | TLote | iEntidade | ESTOQUEFILIAL_LOTE | — | 87 | — |
| uMDFe.pas | TMDFe | iEntidade | MDFE_BASE | 3 | 98 | — |
| uMDFe_NFes.pas | TMDFe_NFes | iEntidade | MDFE_NFES | 1 | 93 | — |
| uMDFe_Percurso.pas | TMDFe_Percurso | iEntidade | MDFE_PERCURSO | 1 | 92 | — |
| uMDFe_Veiculo.pas | TMDFe_Veiculo | iEntidade | MDFE_VEICULO | — | 78 | — |
| uMarca.pas | TMarca | iEntidade | MARCAS1 | — | 83 | — |
| uMunicipio.pas | TMunicipio | iEntidade | MUNICIPIOS | — | 86 | — |
| uNFSe.DAO.pas | TNfse | iEntidade | NFSERVICO | 5 | 97 | — |
| uNFiscalRef.pas | TNiscalRef | iEntidade | NFISCAL_DOCREFERENCIADO | — | 85 | — |
| uNatureza.pas | TNatureza | iEntidade | NATUREZA | — | 93 | — |
| uNaturezaClasse.pas | TNaturezaClasse | iEntidade | NATUREZA_CLASSE | — | 88 | — |
| uNaturezaSubClasse.pas | TNaturezaSubClasse | iEntidade | NATUREZA_SUBCLASSE | — | 88 | — |
| uNcm.pas | TNcm | iEntidade | NCM | 2 | 96 | — |
| uNcmUf.pas | TNcmUf | iEntidade | NCM_UF_IMPOSTOS | — | 85 | — |
| uNfeDuplicatas.pas | TNfeDuplicatas | iEntidade | NFISCAL_DUPLICATAS | — | 85 | — |
| uNfeEntidade.pas | TNfeEntidade | iEntidade | NFISCAL | 5 | 100 | — |
| uNfeItens.pas | TNfeItens | iEntidade | NFISCAL_ITENS | 1 | 101 | — |
| uNfeItensDI.pas | TNfeItensDI | iEntidade | NFISCAL_ITENS_DI | — | 86 | — |
| uNfiscal_Config.pas | TNfiscal_Config | iEntidade | NFISCAL_CONFIG | — | 76 | NewRec |
| uNfiscal_Intermediador.pas | TNfiscal_Intermediador | iEntidade | NFISCAL_INTERMEDIADOR | — | 86 | — |
| uNfse_CodTributacao.pas | TNfse_CodTributacao | iEntidade | NFSERVICO_CODIGOTRIBUTACAO | — | 85 | — |
| uOperadora.pas | TOperadora | iEntidade | OPERADORA | — | 89 | — |
| uOrc_FormaPagamento.pas | TOrc_FormaPagamento | iEntidade | ORC_FORMAPAGAMENTO | — | 86 | — |
| uOrc_Status.pas | TOrc_Status | iEntidade | ORC_STATUS | — | 77 | — |
| uOrcamento.pas | TOrcamento | iEntidade | ORC_PEND | 4 | 104 | — |
| uOrcamentoHistorico.pas | TOrcamentoHistorico | iEntidade | ORC_HISTORICO | — | 80 | — |
| uOrcamentoItens.pas | TOrcamentoItens | iEntidade | PEDIDO | 2 | 130 | Calc, GetText |
| uOrdEquipamentoLocacao.pas | TOrdEquipamentoLocacao | iEntidade | ORD_EQUIPAMENTOS_LOCACAO | 2 | 87 | — |
| uOrdFoto.pas | TOrdemFoto | iEntidade | ORD_FOTO | 2 | 86 | — |
| uOrdStatus.pas | TOrdStatus | iEntidade | ORD_STATUS | 2 | 81 | APP |
| uOrd_Local.pas | TOrd_Local | iEntidade | ORD_LOCAL | — | 79 | — |
| uOrd_Marca.pas | TOrd_Marca | iEntidade | ORD_MARCA | — | 83 | — |
| uOrdemCli.pas | TOrdemCli | iEntidade | ORD_CLI | 8 | 100 | — |
| uOrdemClienteEquipamentoLocal.pas | TOrdCliEqptoLocal | iEntidade | ORD_CLI_EQUIPAMENTO_LOCAL | 1 | 94 | — |
| uOrdemEquipamento.pas | TOrdemEquipamento | iEntidade | ORD_EQUIPAMENTOS | — | 83 | — |
| uOrdemEquipamentoSeriais.pas | TOrdemEquipamentoSeriais | iEntidade | ORD_EQUIPAMENTOS_SERIAIS | 2 | 87 | — |
| uOrdemGarantia.pas | TOrdemGarantia | iEntidade | ORD_GARANTIA | — | 83 | — |
| uOrdemHistorico.pas | TOrdemHistorico | iEntidade | ORD_HISTORICO | — | 79 | — |
| uOrdemJoalheria.pas | TOrdemJoalheria | iEntidade | ORD_JOALHERIA | — | 81 | — |
| uOrdemOtica.pas | TOrdemOtica | iEntidade | ORD_OTICA | — | 84 | — |
| uOrdemOticaLentes.pas | TOrdemOticaLentes | iEntidade | ORD_OTICA_LENTES | — | 84 | — |
| uOrdemPro.pas | TOrdemPro | iEntidade | ORD_PRO | 1 | 94 | — |
| uOrdemStatus.pas | TOrdemStatus | iEntidade | ORD_STATUS | — | 86 | — |
| uPagar.pas | TPagar | iEntidade | PAGAR | 4 | 109 | — |
| uPagarTipoDocumento.pas | TPagarTipoDocumento | iEntidade | PAGAR_TIPODOCUMENTO | — | 86 | — |
| uPais.pas | TPais | iEntidade | PAISES | — | 86 | — |
| uPedido.pas | TPedido | iEntidade | ORC_PEND | 6 | 106 | — |
| uPedidoDeCompra.pas | TPedidoDeCompra | iEntidade | PEDIDODECOMPRA | 2 | 102 | — |
| uPetAgenda.pas | TPetAgenda | iEntidade | PET_AGENDA | 2 | 107 | — |
| uPetAnifoto.pas | TPetAnifoto | iEntidade | PET_ANIMAIS_FOTO | — | 83 | — |
| uPetAnimais.pas | TPetAnimais | iEntidade | PET_ANIMAIS | — | 94 | — |
| uPetCor.pas | TPetCor | iEntidade | PET_COR | — | 84 | — |
| uPetEspecie.pas | TPetEspecie | iEntidade | PET_ESPECIE | — | 85 | — |
| uPetRaca.pas | TPetRaca | iEntidade | PET_RACA | — | 86 | — |
| uPetReceitas.pas | TPetReceitas | iEntidade | PET_RECEITAS | 2 | 79 | — |
| uPetVacina.pas | TPetVacina | iEntidade | PET_VACINA | — | 84 | — |
| uPetVacinaAgenda.pas | TPetVacinaAgenda | iEntidade | PET_VACINA_AGENDA | 6 | 109 | — |
| uPix_Bancos.pas | TPix_Bancos | iEntidade | PIX_BANCOS | — | 76 | — |
| uPix_PspConfig.pas | TPix_PspConfig | iEntidade | PIX_PSP_CONFIG | 1 | 75 | — |
| uPosto_Automacao.pas | TPosto_Automacao | iEntidade | AUTOMACAO | — | 81 | — |
| uPosto_Bicos.pas | TPosto_Bicos | iEntidade | BOMBA | 2 | 94 | — |
| uPosto_Bombas.pas | TPosto_Bombas | iEntidade | BOMBAS | — | 85 | — |
| uPosto_BombasLacres.pas | TPosto_BombasLacres | iEntidade | BOMBAS_LACRES | — | 85 | — |
| uPosto_LmcBomba.pas | TPosto_LmcBomba | iEntidade | LMCBOMBA | — | 85 | — |
| uPosto_LmcTanque.pas | TPosto_LmcTanque | iEntidade | LMCTANQUE | — | 91 | — |
| uPosto_MvTanque.pas | TPosto_MvTanque | iEntidade | MVTANQUE | — | 101 | Calc |
| uPosto_PrecoCliente.pas | TPosto_PrecoCliente | iEntidade | PRECO | — | 97 | — |
| uPosto_Tanques.pas | TPosto_Tanques | iEntidade | TANQUE | — | 90 | — |
| uPrecos.pas | TPrecos | iEntidade | PRECOS | — | 87 | — |
| uPrecosItens.pas | TPrecosItens | iEntidadeProduto | PRECO_ITENS | 3 | 162 | — |
| uPredatado.pas | TPredatado | iEntidade | PREDAT | 5 | 121 | — |
| uPreferencias.pas | TPreferencias | iEntidade | PREFERENCIAS | — | 85 | — |
| uProdInfoNutricional.pas | TProdInfoNutricional | iEntidade | PROD_INFO_NUTRICIONAL | 1 | 90 | — |
| uProducao.pas | TProducao | iEntidade | PRODUCAO | — | 79 | — |
| uProducaoItens.pas | TProducaoItens | iEntidade | PRODUCAO_ITENS | — | 92 | — |
| uProducao_Etiquetas.pas | TProducaoEtiquetas | iEntidade | PRODUCAO_ETIQUETAS | — | 105 | — |
| uProducao_Etiquetas_Composicao.pas | TProducaoEtiquetasComposicao | iEntidade | PRODUTOS_PRODUCAO_ETIQUETAS | — | 98 | — |
| uProduto.pas | TProduto | iEntidadeProduto | PRODUTOS | 29 | 435 | APP |
| uProdutoBarras.pas | TProdutoBarras | iEntidade | PRODUTOS_BARRAS | — | 87 | — |
| uProdutoCadastro.pas | TProdutoCadastro | iEntidadeProduto | PRODUTOS | — | 151 | — |
| uProdutoCor.pas | TProdutoCor | iEntidade | PRODUTOS_CORES | — | 85 | — |
| uProdutoDecomposicao.pas | TProdutoDecomposicao | iEntidade | PRODUTOS_DECOMPOSICAO | — | 91 | — |
| uProdutoDepartamento.pas | TProdutoDepartamento | iEntidade | DEPARTAMENTOS | — | 85 | — |
| uProdutoFornecedor.pas | TProdutoFornecedor | iEntidade | PRODUTOS_FORNECEDOR | — | 83 | — |
| uProdutoImpostos.pas | TProdutoImpostos | iEntidade | PRODUTOS_IMPOSTOS | 2 | 90 | — |
| uProdutoKit.pas | TProdutoKit | iEntidade | PRODUTOS_KIT | — | 83 | — |
| uProdutoLocal.pas | TProdutoLocal | iEntidade | PRODUTOS_LOCAIS | — | 88 | — |
| uProdutoLote.pas | TProdutoLote | iEntidade | ESTOQUEFILIAL_LOTE | — | 88 | — |
| uProdutoLoteEntrada.pas | TProdutoLoteEntrada | iEntidade | ESTFILIAL_LOTE_ENTRADA | — | 89 | — |
| uProdutoPromocao.pas | TProdutoPromocao | iEntidade | PRODUTOS_PROMOCAO | 2 | 95 | — |
| uProdutoSerial.pas | TProdutoSerial | iEntidade | SERIAIS | — | 92 | — |
| uProdutoTamanho.pas | TProdutoTamanho | iEntidade | PRODUTOS_TAMANHO | — | 84 | — |
| uProduto_new.pas | TProduto | iEntidadeProduto | PRODUTOS | 29 | 435 | APP |
| uProdutosFotosUrl.pas | TProdutosFotosUrl | iEntidade | PRODUTOS_FOTOS_URL | 2 | 96 | — |
| uProdutosIcmsSubstituicao.pas | TProdutosIcmsSubstituicao | iEntidade | PRODUTOS_ICMSSUBSTITUICAO | 2 | 95 | — |
| uProdutos_Grupos_Adicionais.pas | TProdutos_Grupos_Adicionais | iEntidade | PRODUTOS_GP_ADD | 2 | 79 | — |
| uProfissional.pas | TProfissional | iEntidade | PROFISSIONAIS | 5 | 108 | APP |
| uPromocao.pas | TPromocao | iEntidade | PROMOCAO | — | 91 | — |
| uPromocaoCupons.pas | TPromocaoCupons | iEntidade | PROMOCAO_CUPONS | 4 | 103 | — |
| uReceber.pas | TReceber | iEntidade | RECEBER | 3 | 115 | NewRec, Calc, APP |
| uReceber_Boleto.pas | TReceber_Boleto | iEntidade | RECEBER | 1 | 114 | NewRec, Calc, APP |
| uRecebido.pas | TRecebido | iEntidade | RECEBIDO | 1 | 105 | NewRec |
| uReceitasModelos.pas | TReceitasModelos | iEntidade | RECEITAS_MODELOS | — | 73 | — |
| uRequisicaoCompra.pas | TRequisicaoCompra | iEntidade | REQUISICAO_COMPRA | — | 83 | — |
| uRequisicaoCompraGrades.pas | TRequisicaoCompraGrades | iEntidade | REQUISICAO_COMPRA_GRADES | — | 90 | — |
| uRequisicaoCompraItens.pas | TRequisicaoCompraItens | iEntidade | REQUISICAO_COMPRA_ITENS | — | 127 | Calc |
| uSat.pas | TSat | iEntidade | SAT_CADASTRO | 2 | 95 | — |
| uSatItens.pas | TSatItens | iEntidade | SAT_ITENS | 1 | 123 | Calc |
| uSatMvto.pas | TSatMvto | iEntidade | SAT_MOVIMENTO | 4 | 99 | — |
| uSngpcDbc.pas | TSngpcDbc | iEntidade | SNGPC_DCB | — | 84 | — |
| uSubgrupo.pas | TSubgrupo | iEntidade | SUBGRUPOS | — | 82 | — |
| uTamanho.pas | TTamanho | iEntidade | PRODUTOS_TAMANHO | — | 82 | — |
| uTelaPrecoCadastro.pas | TTelaPrecoCadastro | iEntidade | TELA_PRECO | — | 84 | — |
| uTelaPrecoFamilia.pas | TTelaPrecoFamilia | iEntidade | FAMILIA | — | 84 | — |
| uTelaPrecoProdutos.pas | TTelaPrecoProdutos | iEntidade | PRODUTOS_TELA_PRECO | — | 92 | — |
| uTelaPrecoProdutosItens.pas | TTelaPrecoProdutosItens | iEntidade | ITENS_PRODUTO_TELA_PRECO | — | 92 | — |
| uTransportadora.pas | TTransportadora | iEntidade | TRANSPORTADORA | — | 83 | — |
| uUsuario.pas | TUsuario | iEntidade | USUARIO | 1 | 110 | NewRec, APP |
| uVasilhame_Entrada.pas | TVasilhameEntrada | iEntidade | VASILHAME_ENTRADA | 1 | 94 | NewRec |
| uVasilhame_Entrada_itens.pas | TVasilhameEntradaItens | iEntidade | VASILHAME_ENTRADA_ITENS | 1 | 99 | NewRec |
| uVendaAdicionais.pas | TVendaAdicionais | iEntidade | VENDA_ADICIONAIS | 1 | 78 | — |
| uVendaItens.pas | TVendaItens | iEntidade | VENDA | 1 | 131 | NewRec, Calc, APP, GetText |
| uVendaMedUsoContinuo.pas | TVendaMedUsoContinuo | iEntidade | VENDA_MED_USOCONTINUO | — | 81 | — |
| uWhatsappMsgs.pas | TMsgsWhatsapp | iEntidade | WHATSAPP_MSGS | 1 | 97 | — |

Total: 218 entidades (além de `uEntidadeBase.pas`, a base genérica `TEntidadeBase<T>`). Colunas "Tabela" e "Casos" são heurísticas por leitura de texto — conferir no fonte antes de depender delas.
