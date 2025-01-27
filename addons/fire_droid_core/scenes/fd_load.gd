extends Node
## Singleton class containing util methods for background loading.
##
## This class works as a manager for dynamic background loading. It allows to
## enqueue paths of resources to load [b](see [method add_to_queue])[/b].
## Loadings can occurr in a sub-thread or in the main thread.[br]All paths
## must be relative to the project (example: [code]"res://path/to/resource"[/code]).
## [br][br][b]Example:[/b]
## [codeblock]
## # In loading screen:
## func _ready() -> void:
##     # Connect FDLoad signals to local methods
##     FDLoad.finished.connect(_on_loading_finished)
##     FDLoad.progress_changed.connect(_on_progress_changed)
##
##     # Add resources to queue (only first argument is mandatory)
##     FDLoad.add_to_queue( # Passing all arguments
##         "res://scenes/cutscene.tscn", "Control", true, 1,
##         ResourceLoader.CacheMode.CACHE_MODE_REPLACE
##     )
##     FDLoad.add_to_queue("res://scenes/level_scene.tscn") # Passing only path
##
##     # Start loading
##     FDLoad.start()
##
##
## func _on_loading_finished(_has_failures: bool) -> void:
##     # Disconnect FDLoad signals
##     FDLoad.finished.disconnect(_on_loading_finished)
##     FDLoad.progress_changed.disconnect(_on_progress_changed)
##
##     # Change scene to loaded resource
##     FDCore.change_scene_to(
##         await FDLoad.get_loaded("res://scenes/cutscene.tscn")
##     )
##
##
## func _on_progress_changed(progress: float) -> void:
##     $ProgressBar.set_value(progress * 100) # Update progress bar from loading scene
## [/codeblock]
## Internally, [FDLoad] loads all resources by creating load requests
## (inner class [FDLoad.FDLoadRequest]). Those requests are grouped and loaded in batches
## (inner class [FDLoad.FDLoadBatch]).[br][br]The maximum amount of requests inside each
## batch is defined by [member batch_size]. Large batches can reduce processing
## at cost of increase memory usage and longer delay when aborting the loading
## process. Smaller batches can reduce memory usage and short the abortion
## delay, at cost of increase processing.[br][br]
## [b]Recommended [member batch_size] values:[/b][br]
## ▪ Low memory devices (such as mobile, web or VR): [b]3-10 Requests/Batch[/b][br]
## ▪ Projects with lightweight assets: [b]10-20 Requests/Batch[/b][br]
## ▪ Projects with heavy assets: [b]50-100 Requests/Batch[/b][br]
## ▪ Background processing: [b]30-50 Requests/Batch[/b][br]
## [br]In some cases, resources may fail to load.
## If a resource load fails, resource's path is added to a list that can be
## accessed by calling [method get_failure_paths].[br][br]
## [b]Example:[/b]
## [codeblock]
## func _ready() -> void:
##     # Connect failed signal
##     FDLoad.failed.connect(_on_loading_failed)
##     # ...more code...
##
## func _on_loading_failed() -> void:
##     FDLoad.failed.disconnect(_on_loading_failed) # Disconnect FDLoad signal
##     FDCore.warning("Loading has failed. List of failures path:")
##     for failure_path: String in FDLoad.get_failure_paths():
##         print("> %s" % failure_path)
## [/codeblock]
## It is also possible to change behaviour of load on fails. To abort the
## load on request fail, set flag [member abort_on_failure].[br]If the load is
## aborted, by default all remaining requests are discarded. To keep unprocessed
## requests after abortion, set flag [member keep_unloaded_on_fail].[br][br]
## To get the paths in the queue, use [method get_queue_paths].


## Emitted when a load starts. [b]See [method start].[/b]
signal started()
## Emitted when all batches have finished loading. If [member abort_on_failure]
## is [code]true[/code], this signal means there was no errors in the loading.
signal finished(has_failures: bool)
## Emitted when [member abort_on_failure] is [code]true[/code] and a batch failed
## to load. If [member abort_on_failure] is [code]false[/code], signal
## [signal finished] is emitted with parameter [param has_failure] set to
## [code]true[/code].
signal failed()
## Emitted when the value of a loading is changed. Parameter [param progress] is
## a value between [code]0.0[/code] and [code]1.0[/code]. Connect a method to
## this signal to update visual progress, such as progress bars or labels.
signal progress_changed(progress: float)


## Default retry limit for requests on fail. This value can be overriden for a
## request, when adding the path to the load queue. Set this value to
## [code]0[/code] to avoid retry when a request fail.
## [b]See [method add_to_queue][/b].
var default_retry_limit: int = 1
## Default cache mode for loaded resource. This value can be overriden for a
## request, when adding the path to the load queue.
## [b]See [method add_to_queue], [enum ResourceLoader.CacheMode][/b].
var default_cache_mode: ResourceLoader.CacheMode = (
	ResourceLoader.CacheMode.CACHE_MODE_REUSE
)

## This flag defines the behaviour of loading process on failures. If set to
## [code]true[/code], the entire load process is aborted when a fail occurs.
## If set to [code]false[/code], the loading process will continue even if a
## fail occurs (failed paths can be retrieved by calling [method get_failure_paths]).
var abort_on_failure: bool = false
## This property defines the maximum amount of requests inside each
## batch. Large batches can reduce processing but increase memory usage and
## require a longer delay when aborting the loading process. Smaller batches
## can reduce memory usage and abortion delays, at cost of increase processing.
## [br][br][b]Recommended batch size values:[/b][br]
## ▪ Low memory devices (such as mobile, web or VR): [b]3-10 Requests/Batch[/b][br]
## ▪ Projects with lightweight assets: [b]10-20 Requests/Batch[/b][br]
## ▪ Projects with heavy assets: [b]50-100 Requests/Batch[/b][br]
## ▪ Background processing: [b]30-50 Requests/Batch[/b]
var batch_size: int = 10
## This flag defines the behaviour of remaining requests on failures. If set to
## [code]false[/code], all requests in queue are discarded if the loading process
## fails. If set to [code]true[/code], the remaining unloaded requests are kept
## in the queue and the loading process can be manually restarted.
var keep_unloaded_on_fail: bool = false
var _load_queue: Array[FDLoadRequest] = []
var _batches: Array[FDLoadBatch] = []
var _current_batch_index: int = 0
var _failure_paths: PackedStringArray = []
var _current_failure_index: int = 0
var _is_loading: bool = false
var _last_was_aborted: bool = false


func _ready() -> void:
	set_process(false)
	set_physics_process(false)


func _process(_delta: float) -> void:
	pass


func _physics_process(_delta: float) -> void:
	pass


## This method create a request and add it to the loading queue. [b]Loading queue
## can only be modified if no loading is in progress.[/b][br][br]Adding a resource
## to the loading queue requires only its relative path (example:
## [code]"res://path/to/resource"[/code]), passed by [param path] paremeter.[br]
## [br]The type of the resource can be specified in [param type_hint] as a [String]
## (default value is [code]""[/code]). If [param use_subthread] is
## [code]false[/code], main thread is used to load instead of subthread (this
## can cause some lag). It is possible to override [member default_retry_limit]
## and [member default_cache_mode] by changing values of [param retry_limit] and
## [param cache_mode], respectively ([b]See ResourceLoader.CacheMode[/b]).
func add_to_queue(
	path: String, type_hint: String = "", use_subthread: bool = true,
	retry_limit: int = default_retry_limit,
	cache_mode: ResourceLoader.CacheMode = default_cache_mode
) -> void:
	if _is_loading:
		FDCore.warning("Cannot add to load queue when loading is in progress")
		return
	var request: FDLoadRequest = FDLoadRequest.new()
	request.path = path
	request.type_hint = type_hint
	request.use_subthread = use_subthread
	request.retry_limit = retry_limit
	request.cache_mode = cache_mode
	_load_queue.append(request)


## Return a list containing all paths added to queue.
func get_queue_paths() -> PackedStringArray:
	var queue_paths: PackedStringArray = []
	queue_paths.resize(_load_queue.size())
	for i: int in _load_queue.size():
		queue_paths[i] = _load_queue[i].path
	return queue_paths


## Remove a request from the load queue by it's [param index]. If the index is
## invalid, nothing happens.
func queue_remove_by_index(index: int) -> void:
	if _is_loading:
		FDCore.warning("Cannot remove from load queue when loading is in progress")
		return
	_load_queue.remove_at(index)


## Remove a request from the load queue by it's [param path]. If the path is
## invalid, nothing happens.
func queue_remove_by_path(path: String) -> void:
	if _is_loading:
		FDCore.warning("Cannot remove from load queue when loading is in progress")
		return
	var index: int = _find_request_index_by_path(path)
	if index < 0:
		return
	_load_queue.remove_at(index)


## Remove all requests from the load queue.
func clear_queue() -> void:
	if _is_loading:
		FDCore.warning("Cannot clear load queue when loading is in progress")
		return
	for request: FDLoadRequest in _load_queue:
		request.queue_free()
	_load_queue.clear()


## Start the load process. If another loading is in progress, a warning is shown
## and the new loading is not started.[br][br]Internally, this method group all
## requests in batches, them process them one by one.[br][br]When the loading
## is started, signal [signal started] is emitted. If the load queue is empty,
## signal [signal finished] is emitted imediatelly.
func start() -> void:
	if _is_loading:
		FDCore.warning("Cannot start loading when another loading is in progress")
		return
	_clear_all_batches()
	_is_loading = true
	FDCore.log_message("Started the loading of %d resources" % _load_queue.size())
	started.emit()
	progress_changed.emit(0.0)
	if _load_queue.is_empty():
		FDCore.log_message("Loading finished with empty queue")
		finished.emit()
		_is_loading = false
		_last_was_aborted = false
		return
	var batches_count: int = ceil(float(_load_queue.size()) / float(batch_size))
	_batches.resize(batches_count)
	FDCore.log_message("Initializing %d batches" % batches_count)
	for i: int in _batches.size():
		_batches[i] = FDLoadBatch.new(i, _load_queue)
		_batches[i].finished.connect(_on_batch_finished)
		_batches[i].failed.connect(_on_batch_failed)
		_batches[i].progress_sum_changed.connect(_on_batch_progress_sum_changed)
	_current_batch_index = 0
	_current_failure_index = 0
	_failure_paths.clear()
	FDCore.log_message("Adding batch %d to scene tree" % _current_batch_index)
	add_child(_batches[0])
	_batches[0].start_load()


## Return the loading progress of the current loading process. The progress is a
## float value between [code]0.0[/code] and [code]1.0[/code].[br][br]If the queue
## is empty or no load is in progress, the returned value is [code]1.0[/code].
func get_progress() -> float:
	if _load_queue.is_empty() or not _is_loading:
		return 1.0
	var total_sum: int = 0
	for batch: FDLoadBatch in _batches:
		total_sum += batch.get_progress_sum()
	return float(total_sum) / float(_load_queue.size() * 100)


## Check if the resource located in [param path] is loaded in the memory cache.
func has_loaded(path: String) -> bool:
	return ResourceLoader.has_cached(path)


## Return [code]true[/code] if last loading had any failure.[br]This method is
## a short way to [code]FDLoad.get_failure_paths().size() > 0[/code].
func has_failures() -> bool:
	return _failure_paths.size() > 0


## Return a loaded resource by passing it's [param path]. Optional parameters
## can be passed:[br][br]
## ▪ [param type_hint] is the target type of the resource, as a [String];[br]
## ▪ [param use_subthread] is a flag to select wich thread will be used to the
## load. If [code]false[/code], main thread is used instead of sub-thread;[br]
## ▪ [param retry_limit] is the max amount of retry for resource loadings with
## errors. This value can be different to each request ([b]See
## [member default_retry_limit][/b]);[br]
## ▪ [param cache_mode] is the mode that must be used to manage the resource
## once it is loaded to the memory cache ([b]See [ResourceLoader.CacheMode],
## [member default_cache_mode][/b]).[br][br]If a resource isn't cached in
## memory, it is loaded individually and returned.
func get_loaded(
	path: String,
	type_hint: String = "", use_subthread: bool = true,
	retry_limit: int = default_retry_limit,
	cache_mode: ResourceLoader.CacheMode = default_cache_mode
) -> Resource:
	if ResourceLoader.has_cached(path):
		return ResourceLoader.load_threaded_get(path)
	var error: int = ResourceLoader.load_threaded_request(
		path, type_hint, use_subthread, cache_mode
	)
	if error:
		FDCore.warning("Failed to load resource at \"%s\"" % path)
		return null
	var loaded: Resource = await ResourceLoader.load_threaded_get(path)
	return loaded


## Return [code]true[/code] if a loading is currently in progress, or
## [code]false[/code] if not.
func is_loading() -> bool:
	return _is_loading


## Return a list of every resource path with failure. If [member abort_on_failure]
## is [code]true[/code], the list will contain only the first failure path.[br][br]
## When a new load is started, the previous failure paths array is discarded.
func get_failure_paths() -> PackedStringArray:
	return _failure_paths


## Return [code]true[/code] if last loading was aborted. If the load has finished
## with failures but [member abort_on_fail] is set to [code]false[/code], this
## method return [code]false[/code].
func last_was_aborted() -> bool:
	return _last_was_aborted


# This method is an auxiliar to queue_remove_by_path.
func _find_request_index_by_path(path: String) -> int:
	var index: int = 0
	for request: FDLoadRequest in _load_queue:
		if request.path == path:
			return index
		index += 1
	return -1


# This method is called when the signal failed is received from a resource.
func _append_failure(path: String) -> void:
	_failure_paths[_current_failure_index] = path
	_current_failure_index += 1


func _abort_all_batches() -> void:
	for batch: FDLoadBatch in _batches:
		batch.abort()


# This method clear the requests array from all batches.
# If param free_requests is true, all requests in the batches are deleted.
func _clear_all_batches(free_requests: bool = false) -> void:
	if _is_loading:
		FDCore.warning("Cannot clear batches when loading is in progress")
		return
	for batch: FDLoadBatch in _batches:
		batch.clear(free_requests)
		batch.queue_free()
	_batches.clear()


# When a batch finish the loading of it's requests, the batch is removed from
# scene tree and the next batch is added. If finished batch is the last one,
# the loading process is finished, the signal finished is emitted and all batches
# are clean.
func _on_batch_finished() -> void:
	remove_child(_batches[_current_batch_index])
	FDCore.log_message("Finished to load batch %d" % _current_batch_index)
	_current_batch_index += 1
	if _current_batch_index >= _batches.size():
		FDCore.log_message("Finished to load all batches")
		finished.emit(not _failure_paths.is_empty())
		_last_was_aborted = false
		_clear_all_batches(true)
		_load_queue.clear()
		_is_loading = false
		progress_changed.emit(1.0)
		return
	add_child(_batches[_current_batch_index])
	FDCore.log_message("Adding batch %d to scene tree" % _current_batch_index)
	await _batches[_current_batch_index].ready
	_batches[_current_batch_index].start_load()


# This method clean a batch when it fails. If abort_on_failure is true, the
# loading process is aborted. On abort, if keep_unloaded_on_fail is false, all
# requests are deleted and clean.
func _on_batch_failed(_failure_batch: FDLoadBatch) -> void:
	var can_clear_requests: bool = (not keep_unloaded_on_fail)
	_failure_batch.clear(can_clear_requests)
	if abort_on_failure:
		_clear_all_batches(can_clear_requests)
		failed.emit()
		_last_was_aborted = true
		return


# Emitted at every progress sum from a batch. Progress sum is the sum of the
# progress of every request in a batch. The value of sum is an integer, to
# optimize divisions and multiplications, adding instead of multiplying and
# dividing only when getting total progress (one division for all requests
# instead of one division for each request).
func _on_batch_progress_sum_changed(_progress_sum: int) -> void:
	progress_changed.emit(get_progress())


class FDLoadRequest extends Node:
	signal finished()
	signal failed()
	signal progress_changed(previous_progress: int, current_progress: int)


	var path: String = ""
	var type_hint: String = ""
	var use_subthread: bool = true
	var retry_limit: int = FDLoad.default_retry_limit
	var cache_mode: ResourceLoader.CacheMode = FDLoad.default_cache_mode
	var _current_progress: int = 0
	var _progress_array: Array = [0.0]
	var _previous_progress: int = 0


	func _ready() -> void:
		set_process(false)
		set_physics_process(false)


	func _process(_delta: float) -> void:
		if not _previous_progress == _current_progress:
			progress_changed.emit(_previous_progress, _current_progress)
		if is_loaded():
			FDCore.log_message("FDLoadRequest finished to load path \"%s\"" % path)
			finished.emit()
			set_process(false)


	func get_progress() -> float:
		return _progress_array[0]


	func start_load() -> void:
		FDCore.log_message("Request started to load path \"%s\"" % path)
		if path.is_empty():
			_progress_array[0] = 1.0
			_current_progress = 100
			finished.emit()
			return
		elif is_loaded():
			finished.emit()
			return
		if _request_load():
			return
		for i: int in retry_limit:
			if _request_load():
				return
		failed.emit()


	func is_loaded() -> bool:
		_previous_progress = _current_progress
		var load_status: int = (
			ResourceLoader.load_threaded_get_status(path, _progress_array)
		)
		_current_progress = int(_progress_array[0] * 100)
		return (
			load_status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED
		)


	func _request_load() -> bool:
		var error: int = ResourceLoader.load_threaded_request(
			path, type_hint, use_subthread, cache_mode
		)
		if not error:
			set_process(true)
			return true
		return false


class FDLoadBatch extends Node:
	signal finished(batch: FDLoadBatch)
	signal failed(batch: FDLoadBatch)
	signal progress_sum_changed(progress_sum: int)


	var _requests: Array[FDLoadRequest] = []
	var _is_aborted: bool = false
	var _has_started: bool = false
	var _progress_sum: int = 0
	var _finished_count: int = 0


	func _init(batch_index: int, load_queue: Array[FDLoadRequest]) -> void:
		_requests = load_queue.slice(batch_index, FDLoad.batch_size)


	func _ready() -> void:
		set_process(false)
		set_physics_process(false)
		for request: FDLoadRequest in _requests:
			add_child(request)
			request.finished.connect(_on_request_finished)
			request.progress_changed.connect(_on_request_progress_changed)


	func abort() -> void:
		_is_aborted = true


	func clear(free_requests: bool = false) -> void:
		if free_requests:
			for request: FDLoadRequest in _requests:
				request.queue_free()
		_requests.clear()


	func get_progress_sum() -> int:
		return _progress_sum


	func start_load() -> void:
		if _has_started:
			FDCore.log_message(
				"Restarting a batch is forbidden. Try creating a new one!"
			)
			return
		_has_started = true
		FDCore.log_message("Batch started to load %d requests" % _requests.size())
		if _is_aborted:
			return
		for request: FDLoadRequest in _requests:
			request.start_load()


	func has_finished() -> bool:
		return _finished_count == _requests.size()


	func _on_request_finished() -> void:
		_finished_count += 1
		if _finished_count == _requests.size():
			finished.emit()


	func _on_request_failed(request: FDLoadRequest) -> void:
		FDLoad._append_failure(request.path)
		if FDLoad.abort_on_failure:
			failed.emit(self)
			return


	func _on_request_progress_changed(
		previous_progress: float, current_progress: float
	) -> void:
		_progress_sum += current_progress - previous_progress
		progress_sum_changed.emit(_progress_sum)
