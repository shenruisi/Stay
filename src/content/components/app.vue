<template>
	<div class="content_page">
		content_page
		<div class="content_page_main">
			content_page_main
		</div>
		<div class="content_page_footer">
			content_page_footer
		</div>
	</div>
</template>

<script>
	export default {

	}
</script>

<style lang="less" scoped>
	.content_page{
		color: red;
		position: fixed;
		z-index: 100001;
		right: 10px;
		bottom: 10px;
		.content_page_main{
			color: green;
		}
	}
</style>