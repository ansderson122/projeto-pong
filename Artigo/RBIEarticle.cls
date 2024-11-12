%=======================================================================
% Classe LaTeX para artigos da RBIE
%
% Copyright (C) 2022 RBIE
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
%=======================================================================

%=======================================================================
% Identificacao
%=======================================================================
\NeedsTeXFormat{LaTeX2e}
%\ProvidesClass{RBIEarticle}[2021/03/08 v3.0 Artigos para a RBIE - Agradecimentos Gabriel de Souza Leitão e Edwin Monteiro: https://github.com/gbrleitao/rbie_latex]
%\ProvidesClass{RBIEarticle}[2021/03/08 v3.1 Artigos para a RBIE]
\ProvidesClass{RBIEarticle}[2022/08/23 v3.2 Artigos para a RBIE]

%=======================================================================
% Declaracoes basicas
%=======================================================================
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ProcessOptions\relax
\LoadClass[a4paper,12pt]{article}
\RequirePackage{graphicx} % funcoes para manipular o logotipo da RBIE
\RequirePackage{babel}
\RequirePackage{times} % define a fonte principal para Times
\RequirePackage{mathptmx} % define Times tambem para as equacoes
\RequirePackage{listings} % para formatacao de codigo-fonte
	\lstset{
		basicstyle=\scriptsize\ttfamily,
		frame=single
	}

\usepackage{hyperref} % criar bookmarks in latexs
\newcommand*{\doi}[1]{\href{http://doi.org/#1}{#1}}
%\newcommand{\APACrefnote}[1]{\ifx\@empty#1\@empty\else[{#1}]\fi}
\usepackage{lipsum}	% texto aleatorio



%\RequirePackage{apacite} % para formatacao de referencias bibliograficas
%	\bibliographystyle{myapacite}
%	\AtBeginDocument{\urlstyle{APACsame}}
\renewcommand{\thepage}{\ifnum\value{page}<10 0\fi\arabic{page}} % coloca as páginas de 1 a 9 com dois dígitos

\hypersetup{
  colorlinks = true, %Colours links instead of ugly boxes
  urlcolor   = blue, %Colour for external hyperlinks
  linkcolor  = black, %Colour of internal links
  citecolor  = black, %Colour of citations
  bookmarksopen = true, %If Acrobat bookmarks are requested, all the subtrees expanded.
  bookmarksopenlevel = 2,
  pdfstartview = Fit,
  unicode = true
}

%=======================================================================
% Margens e espacamentos
%=======================================================================
% ajuste das medidas verticais
\setlength{\topmargin}{12.5mm}
\setlength{\headheight}{12.5mm}
\setlength{\headsep}{8mm}
\setlength{\footskip}{20mm}
\newlength{\@RBIEfootsep}\setlength{\@RBIEfootsep}{12.5mm}
\setlength{\textheight}{\paperheight}
	\addtolength{\textheight}{-\topmargin}
	\addtolength{\textheight}{-\headheight}
	\addtolength{\textheight}{-\headsep}
	\addtolength{\textheight}{-\footskip}
	\addtolength{\textheight}{-\@RBIEfootsep}
\setlength{\topskip}{0pt}
\addtolength{\topmargin}{-1in}

% ajuste das medidas horizontais: esq/dir 20mm
\setlength{\oddsidemargin}{23mm}
\setlength{\textwidth}{\paperwidth}
	\addtolength{\textwidth}{-2\oddsidemargin}
\addtolength{\oddsidemargin}{-1in}
\setlength{\evensidemargin}{\oddsidemargin}
\setlength{\parskip}{6pt}
\setlength{\parindent}{1cm}
%\sloppy % deixa o LaTeX mais tolerante com os espacamentos horizontais

%=======================================================================
% Comandos para informacoes gerais
%=======================================================================
\DeclareRobustCommand{\titleinenglish}[1]{\gdef\@titleeng{#1}}
\DeclareRobustCommand{\titleinspanish}[1]{\gdef\@titlespanish{#1}}
\DeclareRobustCommand{\heading}[2]{\gdef\@headingL{#1} \gdef\@headingR{#2}}
\DeclareRobustCommand{\citeas}[1]{\gdef\@citeas{#1}}

\DeclareRobustCommand{\Submission}[1]{\gdef\@Submission{#1}}
\DeclareRobustCommand{\Camera_ready}[1]{\gdef\@Camera_ready{#1}}
\DeclareRobustCommand{\First_round_notif}[1]{\gdef\@First_round_notif{#1}}
\DeclareRobustCommand{\Edition_review}[1]{\gdef\@Edition_review{#1}}
\DeclareRobustCommand{\New_version}[1]{\gdef\@New_version{#1}}
\DeclareRobustCommand{\Available_online}[1]{\gdef\@Available_online{#1}}
\DeclareRobustCommand{\Second_round_notif}[1]{\gdef\@Second_round_notif{#1}}
\DeclareRobustCommand{\Published}[1]{\gdef\@Published{#1}}

%=======================================================================
% Definicoes dependentes do idioma
%=======================================================================
\@namedef{captionsenglish}{
	\def\bibname{References}
	\def\abstractname{Abstract}
	\def\appendixname{Appendix}
	\def\corollaryname{Corollary}
	\def\propositionname{Proposition}
	\def\definitionname{Definition}
	\def\conjecturename{Conjecture}
	\def\examplename{Example}
	\def\exercisename{Exercise}
	\def\propertyname{Property}
	\def\remarknamek{Remark}
	\def\lemmaname{Lemma}
	\def\theoremname{Theorem}
	\def\proofname{Proof}
	\def\figurename{Figure}
	\def\tablename{Table}
	\def\keywordsname{Keywords}
	\def\codename{Code}
}
\@namedef{captionsbrazilian}{
	\def\refname{Refer{\^e}ncias}
	\def\abstractname{Resumo}
	\def\appendixname{Ap{\^e}ndice}
	\def\corollaryname{Corol\'{a}rio}
	\def\propositionname{Proposi\c{c}\~{a}o}
	\def\definitionname{Defini\c{c}\~{a}o}
	\def\conjecturename{Conjectura}
	\def\examplename{Exemplo}
	\def\exercisename{Exerc\'{\i}cio}
	\def\propertyname{Propriedade}
	\def\remarknamek{Observa\c{c}\~{a}o}
	\def\lemmaname{Lema}
	\def\theoremname{Teorema}
	\def\proofname{Prova}
	\def\figurename{Figura}
	\def\tablename{Tabela}
	\def\keywordsname{Palavras-chave}
	\def\codename{C{\'o}digo}
}
\@namedef{captionsspanish}{
	\def\bibname{Referencias}
	\def\abstractname{Resumen}
	\def\appendixname{Apéndice}
	\def\corollaryname{Corolario}
	\def\propositionname{Proposición}
	\def\definitionname{Definición}
	\def\conjecturename{Conjetura}
	\def\examplename{Ejemplo}
	\def\exercisename{Ejercicio}
	\def\propertyname{Propiedad}
	\def\remarknamek{Observación}
	\def\lemmaname{Lema}
	\def\theoremname{Teorema}
	\def\proofname{Prueba}
	\def\figurename{Figura}
	\def\tablename{Tabla}
	\def\keywordsname{Palabras clave}
	\def\codename{Código}
}

%=======================================================================
% Cabecalho e rodape
%=======================================================================
\def\@RBIEhead{%
	\raisebox{18pt}[0pt][0pt]{\makebox[0pt][l]{%
		\parbox{\textwidth}{%
			%\raggedleft\includegraphics[width=9mm]{newlogo.png}%
		}%
	}}%
	\parbox[b]{\textwidth}{%
		\fontsize{10}{12}\selectfont%
		\@headingL \hfill \@headingR\\
		\rule[1ex]{\textwidth}{.5pt}
	}%
}

\def\@RBIEfoot{%
	\vbox to 1.5cm{%
		\parbox[b]{\textwidth}{%
			\centering\thepage%
		}%
		\vfil
	}%
}

\def\@RBIEheadfirstpage{%
	\raisebox{5pt}[0pt][0pt]{\makebox[0pt][l]{\includegraphics[scale=0.3]{newlogo.png}}}%
	\parbox{\textwidth}{%
		\begin{flushright}
		\fontsize{11}{13}\selectfont%
		Revista Brasileira de Inform{\'a}tica na Educa{\c{c}}{\~a}o -- RBIE\\
		Brazilian Journal of Computers in Education\\
		(ISSN online: 2317-6121; print: 1414-5685)\\
		\href{https://sol.sbc.org.br/journals/index.php/rbie}{\underline{https://sol.sbc.org.br/journals/index.php/rbie}}
		\vspace{-2ex}
		\end{flushright}
        \rule{\textwidth}{.5pt}%
        
        \vspace{2ex}%
        
        \fontsize{8}{10}\selectfont%
        \hspace*{1ex}%
        \parbox{40mm}{%
        	Submission: \@Submission; \newline % 
            Camera ready: \@Camera_ready; \newline % 
        }
        \parbox{40mm}{%
        	1\textsuperscript{st} round notif.: \@First_round_notif;  \newline % 
            Edition review: \@Edition_review;  \newline % 
        }
        \parbox{40mm}{%
        	New version: \@New_version;  \newline % 
            Available online: \@Available_online; \newline % 
        }
        \parbox{40mm}{%
        	2\textsuperscript{nd} round notif.: \@Second_round_notif; \newline % 
            Published: \@Published; \newline % 
        }
        \rule{\textwidth}{.5pt}%
	}%
}

\def\@RBIEfootfirstpage{%
	\parbox[b]{\textwidth}{%
		\fontsize{10}{12}\selectfont%
		\itshape%
		\setlength{\parindent}{-36pt}%
		\setlength{\leftskip}{36pt}%
			Cite as: \@citeas.
	}%
}

\def\ps@RBIE{%
	\let\@oddhead\@RBIEhead
	\let\@evenhead\@RBIEhead
	\let\@oddfoot\@RBIEfoot
	\let\@evenfoot\@RBIEfoot
}

\def\ps@RBIEfirstpage{%
	\let\@oddhead\@RBIEheadfirstpage
	\let\@evenhead\@RBIEheadfirstpage
	\let\@oddfoot\@RBIEfootfirstpage
	\let\@evenfoot\@RBIEfootfirstpage
}
\pagestyle{RBIE}

%=======================================================================
% Formatação do título e das informações autorais do artigo
%=======================================================================
\DeclareRobustCommand{\maketitle}{%
	% cabecalho e rodape especificos para a primeira pagina
	\thispagestyle{RBIEfirstpage}%

	% espaçamento do cabecalho
	\vspace*{1cm}

	% titulos do artigo
	\begin{center}
		\vspace*{3ex}
		{\fontsize{17}{20}\selectfont\bfseries\@title\par}
		\@ifundefined{@titleeng}{}{%
			\vspace{1.5ex}%
			\bfseries\itshape\foreignlanguage{english}{Title: \@titleeng}\par%
		}%
		\@ifundefined{@titlespanish}{}{%
			\vspace{1.5ex}%
			\bfseries\itshape\foreignlanguage{spanish}{Título: \@titlespanish}\par%
		}%
	\end{center}

	% dados dos autores
	\vspace{6pt}
	\begingroup
		\noindent%
		\fontsize{10}{12}\selectfont%
		\itshape%
		\@author\par
	\endgroup
	\addvspace{4ex}
}

%=======================================================================
% Formatacao do abstract
%=======================================================================
\renewenvironment{abstract}{%
	\setlength{\@tempdima}{\parindent}%
	\setlength{\parindent}{0pt}%
	\setlength{\parskip}{0pt}%
	\textbf{\abstractname}\par
	\begin{itshape}
		\fontsize{10}{12}\selectfont%
}{%
		\par
	\end{itshape}
	\setlength{\parindent}{\@tempdima}%
	\addvspace{24pt}
}

%=======================================================================
% Indicacao de palavras-chave
%=======================================================================
\DeclareRobustCommand{\keywords}[1]{%
	\par
	\textbf{\keywordsname:\space}%
}

%=======================================================================
% Formatacao do abstract
%=======================================================================
%\renewenvironment{abstract}{%
%	\setlength{\@tempdima}{\parindent}%
%	\setlength{\parindent}{0pt}%
%	\setlength{\parskip}{0pt}%
%	\textbf{\abstractname}\par
%	\begin{itshape}
%		\fontsize{10}{12}\selectfont%
%}{%
%		\par
%	\end{itshape}
%	\setlength{\parindent}{\@tempdima}%
%	\addvspace{24pt}
%}

%=======================================================================
% Indicacao de palavras-chave
%=======================================================================
%\DeclareRobustCommand{\keywords}[1]{%
%	\par
%	\textbf{\keywordsname:\space}%
%}

%=======================================================================
% Formatacao dos titulos de secoes
%=======================================================================
\DeclareRobustCommand{\section}{%
	\@startsection{section}{1}{\z@}{-24pt}{12pt}%
		{\fontsize{14}{17}\selectfont\bfseries}%
}
\DeclareRobustCommand{\subsection}{%
	\@startsection{subsection}{2}{\z@}{-12pt}{6pt}%
		{\bfseries}%
}
\DeclareRobustCommand{\subsubsection}{%
	\@startsection{subsubsection}{3}{\z@}{-12pt}{6pt}%
		{\itshape}%
}

%=======================================================================
% Formatacao das legendas de figuras, tabelas, etc.
%=======================================================================
\setlength{\abovecaptionskip}{6pt}
\setlength{\belowcaptionskip}{6pt}
\long\def\@makecaption#1#2{%
  \vskip\abovecaptionskip
  \sbox\@tempboxa{{\scriptsize #1: #2.}}%
  \ifdim \wd\@tempboxa >\hsize
    {\scriptsize #1: #2.\par}
  \else
    \global \@minipagefalse
    \hb@xt@\hsize{\hfil\box\@tempboxa\hfil}%
  \fi
  \vskip\belowcaptionskip}

%=======================================================================
% Environment para formatacao de codigo
%=======================================================================
\newcounter{code}
\renewcommand\thecode{\@arabic\c@code}
\def\fps@code{tbp}
\def\ftype@code{3}
\def\ext@code{loc}
\def\fnum@code{\codename\nobreakspace\thecode}
\newenvironment{code}
	       {\@float{code}}
	       {\end@float}

%=======================================================================
% Parametros do pacote listings para produzir codigo-fonte conforme
% o padrao exigido pela revista.
%=======================================================================
\lstset{
	basicstyle=\scriptsize\ttfamily,
	frame=single
}