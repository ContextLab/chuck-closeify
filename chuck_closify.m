function[] = chuck_closify(im,rows,cols,outfile)
%CHUCK_CLOSIFY   turn a photo into a "chuck close" style image
%
%The function take an image, and produces a new image comprised of a mosaic
%of abstract building blocks.
%
% Usage: chuck_closify(im,rows,cols,[outfile])
%
% INPUTS:
%       im: an RGB image to be processed.  can either be a filename or an
%           image (matrix).
%
%     rows: number of rows of abstract images to use in the result.
%
%     cols: number of columns of abstract images to use in the result.
%
%  outfile: optional argument specifying a filename to write the new image
%           to.  the new image will be written as a PDF; do not specify a
%           file extension.
%
% OUTPUTS: [none]
%
% SEE ALSO: rectangle, imagesc, imread
%
%  AUTHOR: Jeremy R. Manning
% CONTACT: manning3@princeton.edu

% CHANGELOG:
% 10-23-12  jrm  wrote it.
% 1-3-13    jrm  corrected colors, made tiles and shapes more interesting
%                and varied.

f = gcf; clf;

if ischar(im), im = imread(im); end;

rowsize = floor(size(im,1)/rows);
colsize = floor(size(im,2)/cols);

for i = 1:rows
    rowstart = ((i-1)*rowsize)+1;
    rowend = rowstart+rowsize;
    for j = 1:cols
        colstart = ((j-1)*colsize)+1;
        colend = colstart+colsize;
                
        closify_patch(im,rowstart,rowend,colstart,colend);        
    end
end

axis tight;
axis off;
axis square;

if exist('outfile','var'), print(f,'-dpdf','-painters',outfile); end




function[] = closify_patch(p,rs,re,cs,ce)
h = size(p,1);

width = ce-cs;
height = re-rs;

mean_r = mean(mean(p(rs:min(size(p,1),re),cs:min(size(p,2),ce),1)))/255;
mean_g = mean(mean(p(rs:min(size(p,1),re),cs:min(size(p,2),ce),2)))/255;
mean_b = mean(mean(p(rs:min(size(p,1),re),cs:min(size(p,2),ce),3)))/255;

[sizes,curvatures,colors] = get_sizes_shapes_colors([mean_r mean_g mean_b],2,6);

hold on;
for i = 1:length(sizes)
    rectangle('Position',[cs-(width*sizes(i))/2, h-rs-(height*sizes(i))/2,...
                          width*sizes(i),height*sizes(i)],...
              'FaceColor',colors(i,:),'EdgeColor','none',...
              'Curvature',[curvatures(i) curvatures(i)]);
end
hold off;



function[sizes,curvatures,colors] = get_sizes_shapes_colors(target,min_n,max_n)

n = randi(max_n - min_n) + min_n; %number of shapes in this tile

sizes = sort(rand(1,n),'descend');
sizes(1) = 1;

curvatures = sort(rand(1,n));
curvatures(1) = 0;

colors = rand(n,3);
colors = n.*repmat(target,n,1).*colors./repmat(sum(colors,1),n,1);
colors(colors > 1) = 1;
