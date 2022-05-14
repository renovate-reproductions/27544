ARG PYTHON_VERSION=3.10
FROM aogier/python-poetry:1.1.13-py${PYTHON_VERSION} as poetry

WORKDIR /srv
COPY . .

RUN set -x; . $HOME/.poetry/env \
    && poetry config virtualenvs.create false \
    && poetry install

FROM poetry as test

RUN scripts/test

FROM poetry as release

ARG PYPI_TOKEN
ARG CODECOV_TOKEN

COPY --from=test /srv/coverage.xml .

RUN . $HOME/.poetry/env \
    && poetry publish --build \
        --username __token__ \
        --password $PYPI_TOKEN \
    && codecov -t $CODECOV_TOKEN
