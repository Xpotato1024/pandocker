---
title: "sample-paper"
author: "Pandocker-X"
date: "2026-06-02"
abstract: |
  This sample shows the minimal setup for building a two-column PDF with Pandocker-X.
keywords:
  - Pandocker-X
  - sample
  - report
bibliography: ../bib/references.bib
csl: /app/csl/ieee-with-url.csl
---

# Introduction

Pandocker-X is a template collection for generating PDFs from Markdown.
This sample demonstrates citation handling, equations, a figure, and a table.

## Model

The simple relation in equation @eq:linear is shown below.

$$
y = ax + b
$$ {#eq:linear}

## Figure

```{=latex}
\begin{figure}[htbp]
\centering
\begin{tikzpicture}[scale=0.9]
  \draw[->] (-0.2,0) -- (4.2,0) node[right] {$x$};
  \draw[->] (0,-0.2) -- (0,3.2) node[above] {$y$};
  \draw[thick,blue] (0,0.5) -- (3.6,2.9);
  \node[below right] at (3.6,2.9) {trend};
\end{tikzpicture}
\caption{Sample figure}
\label{fig:sample-trend}
\end{figure}
```

## Table

```{=latex}
\begin{table*}[t]
\centering
\caption{Sample table}
\begin{tabular}{ll}
\toprule
Item & Description \\
\midrule
Input  & Markdown \\
Output & PDF \\
Style  & citeproc \\
\bottomrule
\end{tabular}
\end{table*}
```

## URL

See the [Pandoc manual](https://pandoc.org/MANUAL.html) for details.

# Conclusion

This sample verifies the core paper workflow in a two-column layout.
