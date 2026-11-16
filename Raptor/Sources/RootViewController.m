#import "RootViewController.h"
static UIColor *RaptorRed(void) { return [UIColor colorWithRed:0.88 green:0.08 blue:0.12 alpha:1.0]; }
@interface RaptorVideo : NSObject
@property(nonatomic,copy) NSString *videoID, *title, *author, *thumbnail;
@end
@implementation RaptorVideo @end
@interface RootViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
@property(nonatomic,strong) UITableView *table;
@property(nonatomic,strong) UISearchBar *search;
@property(nonatomic,strong) NSMutableArray *videos;
@property(nonatomic,strong) UILabel *status;
@property(nonatomic,strong) UIView *playerHost;
@end
@implementation RootViewController
- (void)viewDidLoad {
 [super viewDidLoad]; self.view.backgroundColor=[UIColor colorWithWhite:.97 alpha:1]; self.videos=[NSMutableArray array]; [self buildInterface]; [self searchFor:@"popular music"];
}
- (void)buildInterface {
 CGFloat w=self.view.bounds.size.width;
 UIView *header=[[UIView alloc]initWithFrame:CGRectMake(0,0,w,58)]; header.backgroundColor=[UIColor whiteColor]; header.autoresizingMask=UIViewAutoresizingFlexibleWidth; [self.view addSubview:header];
 UILabel *brand=[[UILabel alloc]initWithFrame:CGRectMake(16,10,220,38)]; brand.text=@"▶  Raptor"; brand.font=[UIFont boldSystemFontOfSize:27]; brand.textColor=RaptorRed(); [header addSubview:brand];
 self.search=[[UISearchBar alloc]initWithFrame:CGRectMake(0,58,w,54)]; self.search.autoresizingMask=UIViewAutoresizingFlexibleWidth; self.search.delegate=self; self.search.placeholder=@"Pesquisar vídeos"; self.search.searchBarStyle=UISearchBarStyleMinimal; [self.view addSubview:self.search];
 self.playerHost=[[UIView alloc]initWithFrame:CGRectMake(0,112,w,w*9.0/16.0)]; self.playerHost.backgroundColor=[UIColor blackColor]; self.playerHost.autoresizingMask=UIViewAutoresizingFlexibleWidth; [self.view addSubview:self.playerHost];
 CGFloat y=CGRectGetMaxY(self.playerHost.frame); self.table=[[UITableView alloc]initWithFrame:CGRectMake(0,y,w,self.view.bounds.size.height-y) style:UITableViewStylePlain]; self.table.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight; self.table.dataSource=self; self.table.delegate=self; self.table.rowHeight=86; [self.view addSubview:self.table];
 self.status=[[UILabel alloc]initWithFrame:CGRectMake(12,CGRectGetMaxY(self.search.frame)+8,w-24,28)]; self.status.textColor=[UIColor grayColor]; self.status.font=[UIFont systemFontOfSize:12]; self.status.autoresizingMask=UIViewAutoresizingFlexibleWidth; [self.view addSubview:self.status];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)s { [s resignFirstResponder]; [self searchFor:s.text]; }
- (void)searchFor:(NSString *)query {
 if(!query.length)return; self.status.text=@"Buscando vídeos…"; [self.videos removeAllObjects]; [self.table reloadData];
 NSURL *url=[NSURL URLWithString:@"https://www.youtube.com/youtubei/v1/search"]; NSMutableURLRequest *req=[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:25]; req.HTTPMethod=@"POST";
 [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"]; [req setValue:@"https://www.youtube.com" forHTTPHeaderField:@"Origin"];
 NSDictionary *body=@{@"context":@{@"client":@{@"clientName":@"WEB",@"clientVersion":@"2.20240101.00.00",@"hl":@"pt-BR",@"gl":@"BR"}},@"query":query}; req.HTTPBody=[NSJSONSerialization dataWithJSONObject:body options:0 error:nil];
 [[[NSURLSession sharedSession]dataTaskWithRequest:req completionHandler:^(NSData *data,NSURLResponse *response,NSError *error){
  if(error||!data){dispatch_async(dispatch_get_main_queue(),^{self.status.text=[NSString stringWithFormat:@"Falha na conexão: %@",error.localizedDescription?:@"resposta vazia"];});return;}
  NSDictionary *json=[NSJSONSerialization JSONObjectWithData:data options:0 error:nil]; NSMutableArray *found=[NSMutableArray array]; [self collectVideos:json into:found];
  dispatch_async(dispatch_get_main_queue(),^{[self.videos addObjectsFromArray:found];[self.table reloadData];self.status.text=found.count?[NSString stringWithFormat:@"%lu vídeos encontrados",(unsigned long)found.count]:@"Nenhum vídeo retornado. A API pode ter mudado.";});
 }]resume];
}
- (void)collectVideos:(id)obj into:(NSMutableArray *)out {
 if([obj isKindOfClass:[NSDictionary class]]){NSDictionary *d=obj;NSDictionary *r=d[@"videoRenderer"];
  if([r isKindOfClass:[NSDictionary class]]&&[r[@"videoId"] isKindOfClass:[NSString class]]){RaptorVideo *v=[RaptorVideo new];v.videoID=r[@"videoId"];NSMutableArray *parts=[NSMutableArray array];for(id run in r[@"title"][@"runs"])if([run isKindOfClass:[NSDictionary class]]&&[run[@"text"] isKindOfClass:[NSString class]])[parts addObject:run[@"text"]];v.title=[parts componentsJoinedByString:@""];v.author=r[@"ownerText"][@"runs"][0][@"text"]?:@"YouTube";NSArray *ts=r[@"thumbnail"][@"thumbnails"];v.thumbnail=[ts.lastObject isKindOfClass:[NSDictionary class]]?ts.lastObject[@"url"]:nil;[out addObject:v];return;}
  for(id value in d.allValues)[self collectVideos:value into:out];
 }else if([obj isKindOfClass:[NSArray class]])for(id value in obj)[self collectVideos:value into:out];
}
- (NSInteger)tableView:(UITableView *)t numberOfRowsInSection:(NSInteger)s{return self.videos.count;}
- (UITableViewCell *)tableView:(UITableView *)t cellForRowAtIndexPath:(NSIndexPath *)p {
 static NSString *reuse=@"VideoCell";UITableViewCell *cell=[t dequeueReusableCellWithIdentifier:reuse];if(!cell){cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuse];cell.textLabel.font=[UIFont boldSystemFontOfSize:15];cell.textLabel.numberOfLines=2;cell.detailTextLabel.textColor=[UIColor grayColor];}
 RaptorVideo *v=self.videos[p.row];cell.textLabel.text=v.title;cell.detailTextLabel.text=v.author;
 if(v.thumbnail.length){NSURL *u=[NSURL URLWithString:v.thumbnail];[[[NSURLSession sharedSession]dataTaskWithURL:u completionHandler:^(NSData *data,NSURLResponse *r,NSError *e){if(data){UIImage *im=[UIImage imageWithData:data];dispatch_async(dispatch_get_main_queue(),^{UITableViewCell *visible=[t cellForRowAtIndexPath:p];if(visible&&p.row<self.videos.count&&[self.videos[p.row].videoID isEqualToString:v.videoID])visible.imageView.image=im;});}}]resume];}
 return cell;
}
- (void)tableView:(UITableView *)t didSelectRowAtIndexPath:(NSIndexPath *)p {
 [t deselectRowAtIndexPath:p animated:YES];RaptorVideo *v=self.videos[p.row];UIWebView *web=[[UIWebView alloc]initWithFrame:self.playerHost.bounds];web.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;web.backgroundColor=[UIColor blackColor];web.scalesPageToFit=YES;
 NSString *html=[NSString stringWithFormat:@"<html><head><meta name=\"viewport\" content=\"width=device-width,initial-scale=1,maximum-scale=1\"></head><body style=\"margin:0;background:#000\"><iframe width=\"100%%\" height=\"100%%\" src=\"https://www.youtube.com/embed/%@?playsinline=1\" frameborder=\"0\" allowfullscreen></iframe></body></html>",v.videoID];
 [self.playerHost.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];[self.playerHost addSubview:web];[web loadHTMLString:html baseURL:[NSURL URLWithString:@"https://www.youtube.com"]];self.status.text=v.title;
}
- (BOOL)shouldAutorotate{return YES;}
@end
