FROM ruby:3.3.4-slim AS build

ENV BUNDLE_WITHOUT="development test"

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    build-essential \
    git \
    libpq-dev \
    libyaml-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /rails

COPY Gemfile Gemfile.lock ./

RUN gem install bundler:4.0.1 && \
    bundle config set --local frozen true && \
    bundle install --jobs 4 --retry 3

COPY . .


FROM ruby:3.3.4-slim

ENV RAILS_ENV=production \
    BUNDLE_WITHOUT="development test"

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /rails

COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

RUN groupadd --system rails && \
    useradd --system --create-home --gid rails rails && \
    chown -R rails:rails /rails

USER rails

EXPOSE 3000

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
