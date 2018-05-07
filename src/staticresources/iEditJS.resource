        $j = jQuery.noConflict();

 $j(document).ready(function(){

	function windowOffset(elem){
		var iTop = elem.offset().top;
		var iLeft = elem.offset().left;
		var res = {
			top: iTop - $j(window).scrollTop(),
			left: iLeft - $j(window).scrollLeft()
		}
		return res;
	}


	//Inserting required elements.
	var iEditHTML = '<div class="iEdit-img-edit"><canvas class="iEdit-img-edit-can"></canvas><canvas class="iEdit-img-edit-process-can"></canvas><div class="iEdit-img-edit-select"><div class="iEdit-img-edit-select-resize"></div></div><div class="iEdit-img-edit-act iEdit-img-edit-save"> Done </div><div class="iEdit-img-edit-act iEdit-img-edit-cancel"> Cancel </div></div>';
	$j("body").append(iEditHTML);

	//Main Image Editor Object
	window.iEdit = {
		//Caching Selectors
		can: $j('.iEdit-img-edit-can')[0],
		processCan: $j('.iEdit-img-edit-process-can')[0],
		selectionBox: $j('.iEdit-img-edit-select'),
		container: $j('.iEdit-img-edit'),
		saveBtn: $j(".iEdit-img-edit-save"),
		cancelBtn: $j('.iEdit-img-edit-cancel'),

		//Internal Properties
		drag: false,
		resize: false,
		square: true,
		status: false,
		grcx: null,
		grcy: null,
		callback: null,
		imageType: null,
		imageQuality: 1,

		//Open the Image Editor with appropriate settings
		open: function(imgObj, square, callback, imageType, imageQuality){

			if(imgObj.constructor !== File || !imgObj.type.match('image.*')){
				return false;
			}

			this.drag = false;
			this.resize = false;

			//Using the supplied settings or using defaults in case of invalid settings

			this.square = (square === true) ? true : false;
			this.imageQuality = (Number(imageQuality) > 0 && Number(imageQuality) <= 1) ? Number(imageQuality) : 1;

			if(imageType == "jpeg" || imageType == "png" || imageType == "gif" || imageType == "bmp"){ //JPG and any other would default to JPEG//
				this.imageType = imageType;
			}else{
				this.imageType = "jpeg";
			}

			//false: Not In Use
			this.grcx = false;
			this.grcy = false;

			//Checking if callback is a valid function
			var getType = {};
			this.callback = (callback && getType.toString.call(callback) === '[object Function]') ? callback : false;

			this.status = true;

			var ctx = this.can.getContext("2d");

			//Shwoing the conatiner on screen
			iEdit.container.css("display","block").stop().animate({"opacity":"1"});

			var img = new Image();
			var that =  this;

			$j(img).on("load", function(){

				if(img.width > img.height){
					that.can.width = img.width;
					that.can.height = img.height;

					that.can.style.width = ($j(window).width()/2*1)+"px";
					that.can.style.height = (img.height*(($j(window).width()/2*1)/img.width))+"px";


					ctx.fillStyle = '#fff';
					ctx.fillRect(0, 0, that.can.width, that.can.height);

					ctx.drawImage(img, 0, 0, that.can.width, that.can.height);

					iEdit.selectionBox.height($j(that.can).height()-20);
					iEdit.selectionBox.width($j(that.can).height()-20);

					iEdit.selectionBox.css({'left': (($j(window).width()/2) - $j(that.can).height()/2) + 10  + 'px' ,'top': $j(window).height()/2 - $j(that.can).height()/2 - 15 + 'px' });

				}else if(img.width < img.height){

					that.can.width = img.width;
					that.can.height = img.height;

					that.can.style.width = (img.width*(($j(window).height()/3*2)/img.height)) + "px";
					that.can.style.height = ($j(window).height()/3*2) + "px";

					ctx.fillStyle = '#fff';
					ctx.fillRect(0, 0, that.can.width, that.can.height);

					ctx.drawImage(img, 0, 0, that.can.width, that.can.height);

					iEdit.selectionBox.height($j(that.can).width()-20);
					iEdit.selectionBox.width($j(that.can).width()-20);

					iEdit.selectionBox.css({'left': (($j(window).width()/2) - $j(that.can).width()/2) + 10  + 'px' ,'top': $j(window).height()/2 - $j(that.can).width()/2 - 15 + 'px' });


				}else{

					that.can.width = img.width;
					that.can.height = img.height;

					that.can.style.width = ($j(window).height()/4.8*3.3) + "px";
					that.can.style.height = ($j(window).height()/4.8*3.3) + "px";


					ctx.fillStyle = '#fff';
					ctx.fillRect(0, 0, that.can.width, that.can.height);

					ctx.drawImage(img, 0, 0, that.can.width, that.can.height);

					iEdit.selectionBox.height($j(that.can).width()-20);
					iEdit.selectionBox.width($j(that.can).width()-20);

					iEdit.selectionBox.css({'left': (($j(window).width()/2) - $j(that.can).width()/2) + 10  + 'px' ,'top': $j(window).height()/2 - $j(that.can).width()/2 - 15 + 'px' });
				}

			});

			img.src = URL.createObjectURL(imgObj);
			return true;
		},

		//Close the image editor and reset the settings.
		close: function(){
			this.drag = false;
			this.resize = false;
			this.square = true;
			this.status = false;
			this.grcx = undefined;
			this.grcy = undefined;
			this.callback = undefined;

			this.can.height = 0;
			this.can.width = 0;

			this.processCan.height = 0;
			this.processCan.width = 0;

			var pCtx = this.processCan.getContext("2d");
			var ctx = this.can.getContext("2d");

			ctx.clearRect(0, 0, 0, 0);
			pCtx.clearRect(0, 0, 0, 0);

			iEdit.selectionBox.css({
				"height":'0px',
				"width":'0px',
			});

			iEdit.container.stop().animate({
				"opacity":"0"
			}, 300);

			setTimeout(function(){
				iEdit.container.css({"display":"none"});
			}, 300);

		}
	}

	//Set flags to stop tracking mouse movement.
	$j(document).on("mouseup",function(){
		iEdit.drag = false;
		iEdit.resize = false;

		iEdit.grcx = false;
		iEdit.grcy = false;
	});


	//Set flags to start trachong mouse movement.
	iEdit.selectionBox.on("mousedown",function(e){
		var that = $j(this);

		var rcx = e.clientX - windowOffset(that).left;
		var rcy = e.clientY - windowOffset(that).top;

		iEdit.grcx = false;
		iEdit.grcy = false;

		if( (iEdit.selectionBox.width() - rcx <= 28) && (iEdit.selectionBox.height() - rcy <= 28)){
			iEdit.drag = false;
			iEdit.resize = true;
		}else{
			iEdit.drag = true;
			iEdit.resize = false;
		}


	});


	//Track mouse movements when the flags are set.
	$j(document).on('mousemove', function(e){

		var rcx = e.clientX - windowOffset(iEdit.selectionBox).left;
		var rcy = e.clientY - windowOffset(iEdit.selectionBox).top;

		if(iEdit.drag === true && iEdit.status){

			if(iEdit.grcx === false){
				iEdit.grcx = rcx;
			}

			if(iEdit.grcy === false){
				iEdit.grcy = rcy;
			}

			var xMove = e.clientX - iEdit.grcx;
			var yMove = e.clientY - iEdit.grcy;


			if( (xMove + iEdit.selectionBox.width() >= $j(iEdit.can).width() + windowOffset($j(iEdit.can)).left) || xMove <= windowOffset($j(iEdit.can)).left){
				if(xMove <= windowOffset($j(iEdit.can)).left){
					iEdit.selectionBox.css({"left":windowOffset($j(iEdit.can)).left+"px"});
				}else{
					iEdit.selectionBox.css({"left":windowOffset($j(iEdit.can)).left + $j(iEdit.can).width() - iEdit.selectionBox.width() + "px"});
				}
			}else{
				iEdit.selectionBox.css({"left":xMove+"px"});
			}


			if((yMove + iEdit.selectionBox.height() >= $j(iEdit.can).height() + windowOffset($j(iEdit.can)).top) || (yMove <= windowOffset($j(iEdit.can)).top) ){
				if(yMove <= windowOffset($j(iEdit.can)).top){
					iEdit.selectionBox.css({"top":windowOffset($j(iEdit.can)).top+"px"});
				}else{
					iEdit.selectionBox.css({"top":windowOffset($j(iEdit.can)).top + $j(iEdit.can).height() - iEdit.selectionBox.height() + "px"});
				}
			}else{
				iEdit.selectionBox.css({"top":yMove+"px"});
			}

		}else if(iEdit.resize === true && iEdit.status){

			var nWidth = rcx;
			var nHeight = rcy;

			if(iEdit.square){
				if(nWidth >= nHeight){//Width is the dominating dimension;
					nHeight = nWidth;
					if(nWidth < 100){
						nWidth = 100;
						nHeight = 100;
					}
				}else{//Height is the dominating dimension;
					nWidth = nHeight;
					if(nHeight < 100){
						nWidth = 100;
						nHeight = 100;
					}
				}

				if((nWidth + windowOffset(iEdit.selectionBox).left) >= $j(iEdit.can).width() + windowOffset($j(iEdit.can)).left){
					nWidth = (windowOffset($j(iEdit.can)).left + $j(iEdit.can).width()) - (windowOffset(iEdit.selectionBox).left);
					if(windowOffset(iEdit.selectionBox).top + nWidth > $j(iEdit.can).height() + windowOffset($j(iEdit.can)).top){
						nWidth = (windowOffset($j(iEdit.can)).top + $j(iEdit.can).height()) - (windowOffset(iEdit.selectionBox).top);
					}
					nHeight = nWidth;
				}else if((nHeight + windowOffset(iEdit.selectionBox).top) >= $j(iEdit.can).height() + windowOffset($j(iEdit.can)).top){
					nHeight = (windowOffset($j(iEdit.can)).top + $j(iEdit.can).height()) - (windowOffset(iEdit.selectionBox).top);
					if(windowOffset(iEdit.selectionBox).left + nHeight > $j(iEdit.can).width() + windowOffset($j(iEdit.can)).left){
						nHeight = (windowOffset($j(iEdit.can)).left + $j(iEdit.can).width()) - (windowOffset(iEdit.selectionBox).left);
					}
					nWidth = nHeight;
				}


			}else{

				if(nWidth <= 100){
					nWidth = 100;
				}
				if(nHeight <= 100){
					nHeight = 100;
				}
				if(e.clientX >= $j(iEdit.can).width() + windowOffset($j(iEdit.can)).left){    //REASON: nWidth + windowOffset(iEdit.selectionBox).left = e.clientX;
					nWidth = (windowOffset($j(iEdit.can)).left + $j(iEdit.can).width()) - (windowOffset(iEdit.selectionBox).left);
				}
				if(e.clientY >= $j(iEdit.can).height() + windowOffset($j(iEdit.can)).top){	//REASON: Same logic as nWidth
					nHeight = (windowOffset($j(iEdit.can)).top + $j(iEdit.can).height()) - (windowOffset(iEdit.selectionBox).top);
				}
			}

			iEdit.selectionBox.css({
				"width":nWidth+"px",
				"height":nHeight+"px",
			});

		}

	});

	//Process the selected region and return it as an image to the user defined callback.
	iEdit.saveBtn.on("click", function(){

		if(!iEdit.callback){
			iEdit.close();
			return;
		}

		var ratio = iEdit.can.width/$j(iEdit.can).width();

		var h = iEdit.selectionBox.height() * ratio;
		var w = iEdit.selectionBox.width() * ratio;
		var x = (windowOffset(iEdit.selectionBox).left - windowOffset($j(iEdit.can)).left) * ratio;
		var y = (windowOffset(iEdit.selectionBox).top - windowOffset($j(iEdit.can)).top) * ratio;

		iEdit.processCan.height = h;
		iEdit.processCan.width = w;

		var pCtx = iEdit.processCan.getContext("2d");

		pCtx.drawImage(iEdit.can, x, y, w, h, 0, 0, w, h);


		iEdit.callback(iEdit.processCan.toDataURL("image/"+iEdit.imageType, iEdit.imageQuality));
		iEdit.close();

	});

	//Close the canvas without processing the image on cancel.
	iEdit.cancelBtn.on("click", function(){
		iEdit.close();
	});

	//Setup canvas when window is resized.
	$j(window).on("resize", function(){
		if(iEdit.status){
			iEdit.selectionBox.css({'left': (($j(window).width()/2) - $j(iEdit.can).height()/2) + 10  + 'px' ,'top': $j(window).height()/2 - $j(iEdit.can).height()/2 + 10 + 'px' });
		}
	});
});
