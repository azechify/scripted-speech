FROM julia

RUN julia -e "using Pkg; pkg\"add HTTP\"; pkg\"precompile\"" --project=.

COPY ./ ./

ENTRYPOINT ["julia", "--project=."]
CMD ["main.jl"] 
