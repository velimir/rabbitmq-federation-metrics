PROJECT = rabbitmq_federation_metrics
PROJECT_DESCRIPTION = Rabbit Federation metrics
PROJECT_MOD = rabbit_federation_metrics
PROJECT_VERSION = git

define PROJECT_ENV
[
	    {interval, 1000},
	    {items, [message_queue_len]}
	  ]
endef

DEPS = rabbit_common rabbit

DEP_EARLY_PLUGINS = rabbit_common/mk/rabbitmq-early-plugin.mk
DEP_PLUGINS = rabbit_common/mk/rabbitmq-plugin.mk

# FIXME: Use erlang.mk patched for RabbitMQ, while waiting for PRs to be
# reviewed and merged.

ERLANG_MK_REPO = https://github.com/rabbitmq/erlang.mk.git
ERLANG_MK_COMMIT = rabbitmq-tmp

include rabbitmq-components.mk
include erlang.mk
